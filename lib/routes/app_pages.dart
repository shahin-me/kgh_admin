import 'package:get/get.dart';
import 'package:kgh_admin/screens/dashboard_screen.dart';
import 'package:kgh_admin/screens/product_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.DASHBOARD, page: () => const DashboardScreen()),
    GetPage(name: AppRoutes.PRODUCTS, page: () => const ProductsScreen()),
    // GetPage(
    //   name: AppRoutes.ORDERS,
    //   page: () => const OrdersScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.CUSTOMERS,
    //   page: () => const CustomersScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.ANALYTICS,
    //   page: () => const AnalyticsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.SETTINGS,
    //   page: () => const SettingsScreen(),
    // ),
  ];
}
