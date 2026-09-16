import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/auth_controller.dart';
import 'package:pro_23_g_6/controller/home_controller.dart';
import 'package:pro_23_g_6/controller/post_controller.dart';
import 'package:pro_23_g_6/controller/user_controller.dart';
import 'package:pro_23_g_6/repository/auth_repository.dart';
import 'package:pro_23_g_6/repository/post_repository.dart';
import 'package:pro_23_g_6/repository/user_repository.dart';
import 'package:pro_23_g_6/screen/auth/login_screen.dart';
import 'package:pro_23_g_6/service/api_service.dart';
import 'package:pro_23_g_6/translations/app_translations.dart';

void main() {
  Get.put(ApiService());
  Get.put(AuthRepository());
  Get.put(PostRepository());
  Get.put(UserRepository());
  
  // Initialize Controllers early
  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(PostController());
  Get.put(UserController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E54EB)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
