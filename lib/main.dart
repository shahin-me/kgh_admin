import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/routes/app_pages.dart';
import 'package:kgh_admin/routes/app_routes.dart';
import 'package:kgh_admin/utils/app_binding.dart';
import 'package:kgh_admin/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KGH Admin',
      initialBinding: AppBinding(), // এখানে binding add করুন
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.DASHBOARD,
      getPages: AppPages.routes,
    );
  }
}
