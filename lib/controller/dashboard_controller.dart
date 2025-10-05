import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/routes/app_routes.dart';

class DashboardController extends GetxController {
  var totalSales = 12540.obs;
  var totalOrders = 324.obs;
  var totalProducts = 1567.obs;
  var totalCustomers = 8923.obs;

  final List<Map<String, dynamic>> recentOrders = [
    {
      'id': '#001234',
      'customer': 'John Doe',
      'amount': '\$120.00',
      'status': 'Delivered',
      'statusColor': Colors.green,
    },
    {
      'id': '#001235',
      'customer': 'Jane Smith',
      'amount': '\$89.99',
      'status': 'Processing',
      'statusColor': Colors.orange,
    },
    {
      'id': '#001236',
      'customer': 'Mike Johnson',
      'amount': '\$245.50',
      'status': 'Shipped',
      'statusColor': Colors.blue,
    },
    {
      'id': '#001237',
      'customer': 'Sarah Wilson',
      'amount': '\$67.80',
      'status': 'Pending',
      'statusColor': Colors.yellow,
    },
  ].obs;

  final List<Map<String, dynamic>> topProducts = [
    {'name': 'Wireless Headphones', 'sales': 234, 'revenue': '\$4,680'},
    {'name': 'Smart Watch', 'sales': 189, 'revenue': '\$5,670'},
    {'name': 'Laptop Backpack', 'sales': 156, 'revenue': '\$2,340'},
    {'name': 'Phone Case', 'sales': 432, 'revenue': '\$2,160'},
  ].obs;

  void updateStats() {
    totalSales.value += 1000;
    totalOrders.value += 15;
    totalProducts.value += 8;
    totalCustomers.value += 45;
    update();
  }

  // FIXED Navigation methods
  void navigateToDashboard() {
    if (Get.currentRoute != AppRoutes.DASHBOARD) {
      Get.offAllNamed(AppRoutes.DASHBOARD);
    }
  }

  void navigateToProducts() {
    if (Get.currentRoute != AppRoutes.PRODUCTS) {
      Get.toNamed(AppRoutes.PRODUCTS);
    }
  }

  void navigateToOrders() {
    if (Get.currentRoute != AppRoutes.ORDERS) {
      Get.toNamed(AppRoutes.ORDERS);
    }
  }

  void navigateToCustomers() {
    if (Get.currentRoute != AppRoutes.CUSTOMERS) {
      Get.toNamed(AppRoutes.CUSTOMERS);
    }
  }

  void navigateToAnalytics() {
    if (Get.currentRoute != AppRoutes.ANALYTICS) {
      Get.toNamed(AppRoutes.ANALYTICS);
    }
  }

  void navigateToSettings() {
    if (Get.currentRoute != AppRoutes.SETTINGS) {
      Get.toNamed(AppRoutes.SETTINGS);
    }
  }
}
