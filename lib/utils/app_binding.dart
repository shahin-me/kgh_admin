import 'package:get/get.dart';
import 'package:kgh_admin/controller/dashboard_controller.dart';
import 'package:kgh_admin/controller/product_controller.dart';
import 'package:kgh_admin/controller/order_controller.dart';
import 'package:kgh_admin/controller/customer_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => ProductController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    Get.lazyPut(() => CustomerController(), fenix: true);
  }
}
