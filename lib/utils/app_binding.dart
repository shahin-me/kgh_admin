import 'package:get/get.dart';
import 'package:kgh_admin/controller/dashboard_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}
