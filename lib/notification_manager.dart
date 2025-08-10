import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationManager extends ChangeNotifier {
  final List<BunyanNotification> _notifications = [];
  List<BunyanNotification> get notifications =>
      List.unmodifiable(_notifications);

  // عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // إضافة إشعار جديد
  void addNotification(BunyanNotification notification) {
    _notifications.insert(0, notification);
    _saveNotifications();
    notifyListeners();
  }

  // وضع علامة "مقروء" على إشعار
  void markAsRead(String id) {
    final notification = _notifications.firstWhere((n) => n.id == id);
    notification.isRead = true;
    _saveNotifications();
    notifyListeners();
  }

  // وضع علامة "مقروء" على كل الإشعارات
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _saveNotifications();
    notifyListeners();
  }

  // حذف إشعار
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveNotifications();
    notifyListeners();
  }

  // حذف كل الإشعارات المقروءة
  void deleteAllRead() {
    _notifications.removeWhere((n) => n.isRead);
    _saveNotifications();
    notifyListeners();
  }

  // حفظ الإشعارات محلياً
  Future<void> _saveNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString('notifications', jsonEncode(notificationsJson));
  }

  // تحميل الإشعارات المحفوظة
  Future<void> loadNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      _notifications.clear();
      _notifications.addAll(
          decoded.map((json) => BunyanNotification.fromJson(json)).toList());
      notifyListeners();
    }
  }
}

class BunyanNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // e.g., 'info', 'warning', 'error', 'success'
  final Map<String, dynamic>? data;
  bool isRead;

  BunyanNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.data,
    this.isRead = false,
  });

  factory BunyanNotification.fromJson(Map<String, dynamic> json) {
    return BunyanNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data,
      'isRead': isRead,
    };
  }

  // إنشاء إشعار معلومات
  static BunyanNotification createInfo({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return BunyanNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: 'info',
      data: data,
    );
  }

  // إنشاء إشعار نجاح
  static BunyanNotification createSuccess({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return BunyanNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: 'success',
      data: data,
    );
  }

  // إنشاء إشعار تحذير
  static BunyanNotification createWarning({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return BunyanNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: 'warning',
      data: data,
    );
  }

  // إنشاء إشعار خطأ
  static BunyanNotification createError({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return BunyanNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: 'error',
      data: data,
    );
  }
}
