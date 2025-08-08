import 'package:flutter/material.dart';
import 'auth.dart';
import 'dashboard_client.dart';
import 'dashboard_supplier.dart';
import 'dashboard_admin.dart';
import 'product_form.dart';
import 'main_selector_page.dart';
import 'quote_requests.dart';
import 'user_management.dart';
import 'request_sent.dart';
import 'products_list.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const MainSelectorPage(),
    '/auth_client': (context) => const AuthPage(userType: 'client'),
    '/auth_supplier': (context) => const AuthPage(userType: 'supplier'),
    '/dashboard_client': (context) => const ClientDashboard(),
    '/dashboard_supplier': (context) => const SupplierDashboard(),
    '/dashboard_admin': (context) => const AdminDashboard(),
    '/product_form': (context) => const ProductFormPage(),
    '/quote_requests': (context) => const QuoteRequestsPage(),
    '/user_management': (context) => const UserManagementPage(),
    '/request_sent': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return RequestSentPage(
        productName: args?['productName'],
        requestDetails: args?['requestDetails'],
      );
    },
    '/products': (context) => const ProductsListPage(),
  };
}
