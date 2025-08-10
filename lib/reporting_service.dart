import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'cache_manager.dart';

class ReportingService extends ChangeNotifier {
  final Map<String, Report> _reports = {};
  List<Report> get reports => _reports.values.toList();

  // إنشاء تقرير جديد
  Future<Report> createReport({
    required String title,
    required String type,
    required Map<String, dynamic> data,
    String? description,
  }) async {
    final report = Report(
      id: 'REP-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      data: data,
      description: description,
      createdAt: DateTime.now(),
      status: ReportStatus.pending,
    );

    _reports[report.id] = report;
    await _saveReport(report);
    notifyListeners();
    return report;
  }

  // تحديث حالة تقرير
  Future<void> updateReportStatus(
      String reportId, ReportStatus newStatus) async {
    if (_reports.containsKey(reportId)) {
      _reports[reportId] = _reports[reportId]!.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await _saveReport(_reports[reportId]!);
      notifyListeners();
    }
  }

  // حذف تقرير
  Future<void> deleteReport(String reportId) async {
    if (_reports.containsKey(reportId)) {
      _reports.remove(reportId);
      await _deleteReportFile(reportId);
      notifyListeners();
    }
  }

  // تصدير تقرير إلى ملف
  Future<String> exportReport(String reportId, ExportFormat format) async {
    final report = _reports[reportId];
    if (report == null) throw Exception('التقرير غير موجود');

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'report_${report.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

    switch (format) {
      case ExportFormat.pdf:
        return await _exportToPDF(report, directory.path, fileName);
      case ExportFormat.excel:
        return await _exportToExcel(report, directory.path, fileName);
      case ExportFormat.json:
        return await _exportToJSON(report, directory.path, fileName);
    }
  }

  // حفظ التقرير
  Future<void> _saveReport(Report report) async {
    try {
      final reportJson = jsonEncode(report.toJson());
      await CacheManager.cacheFile(
        'report_${report.id}',
        utf8.encode(reportJson),
      );
    } catch (e) {
      debugPrint('خطأ في حفظ التقرير: $e');
    }
  }

  // حذف ملف التقرير
  Future<void> _deleteReportFile(String reportId) async {
    try {
      await CacheManager.removeFromCache('report_$reportId');
    } catch (e) {
      debugPrint('خطأ في حذف ملف التقرير: $e');
    }
  }

  // تصدير إلى PDF (محاكاة)
  Future<String> _exportToPDF(
      Report report, String path, String fileName) async {
    // في بيئة الإنتاج، استخدم مكتبة مثل pdf أو syncfusion_flutter_pdf
    final file = File('$path/$fileName.pdf');
    await file.writeAsString('PDF Report Mock: ${report.title}');
    return file.path;
  }

  // تصدير إلى Excel (محاكاة)
  Future<String> _exportToExcel(
      Report report, String path, String fileName) async {
    // في بيئة الإنتاج، استخدم مكتبة مثل excel أو syncfusion_flutter_xlsio
    final file = File('$path/$fileName.xlsx');
    await file.writeAsString('Excel Report Mock: ${report.title}');
    return file.path;
  }

  // تصدير إلى JSON
  Future<String> _exportToJSON(
      Report report, String path, String fileName) async {
    final file = File('$path/$fileName.json');
    await file.writeAsString(jsonEncode(report.toJson()));
    return file.path;
  }
}

class Report {
  final String id;
  final String title;
  final String type;
  final String? description;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReportStatus status;

  Report({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    required this.data,
    required this.createdAt,
    this.updatedAt,
    this.status = ReportStatus.pending,
  });

  Report copyWith({
    String? title,
    String? type,
    String? description,
    Map<String, dynamic>? data,
    ReportStatus? status,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      data: data ?? this.data,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      description: json['description'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }
}

enum ReportStatus {
  pending,
  processing,
  completed,
  failed,
}

enum ExportFormat {
  pdf,
  excel,
  json,
}
