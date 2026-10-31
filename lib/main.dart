import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Earthquake Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialBinding: BindingsBuilder(() {
        if (!Get.isRegistered<AppController>()) {
          Get.put(AppController(), permanent: true);
        }
      }),
      builder: EasyLoading.init(),
      home: const Homepage(),
    );
  }
}
