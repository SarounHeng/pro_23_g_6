import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/auth_controller.dart';
import 'package:pro_23_g_6/screen/home/home_screen.dart';
import 'package:pro_23_g_6/screen/post/create_post_screen.dart';
import 'package:pro_23_g_6/screen/post/post_screen.dart';
import 'package:pro_23_g_6/screen/setting/setting_screen.dart';
import 'package:pro_23_g_6/screen/user/create_user_screen.dart';
import 'package:pro_23_g_6/screen/user/user_screen.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final List<String> titles = ['Home', 'Posts', 'Users', 'Settings'];

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          titles[currentIndex].tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff172033),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfff8f9fa),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 30,
              ),
              color: const Color(0xFF0E54EB),
              child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        backgroundImage: authController.profileImage.value != null
                            ? (kIsWeb
                                ? NetworkImage(authController.profileImage.value!.path)
                                : FileImage(File(authController.profileImage.value!.path))
                                    as ImageProvider)
                            : (authController.currentUserImageUrl.value.isNotEmpty
                                ? NetworkImage(
                                    Get.find<ApiService>().resolveImageUrl(
                                        authController
                                            .currentUserImageUrl.value),
                                    headers: Get.find<ApiService>().token !=
                                            null
                                        ? {
                                            'Authorization':
                                                'Bearer ${Get.find<ApiService>().token}'
                                          }
                                        : null,
                                  )
                                : null),
                        child: authController.profileImage.value == null &&
                                authController.currentUserImageUrl.value.isEmpty
                            ? Text(
                                authController.currentUserName.value.isNotEmpty
                                    ? authController.currentUserName.value
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : "?",
                                style: const TextStyle(fontSize: 20))
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        authController.currentUserName.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        authController.currentUserEmail.value,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )),
            ),

            // Home
            ListTile(
              leading: const Icon(Icons.home),
              title: Text("Home".tr),
              onTap: () {
                setState(() => currentIndex = 0);
                Navigator.pop(context);
              },
            ),

            // New User
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text("New user".tr),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const CreateUserScreen());
              },
            ),

            // Language
            ListTile(
              leading: const Icon(Icons.language),
              title: Text("Language".tr),
              trailing: Text(
                Get.locale?.languageCode == 'km' ? 'Khmer'.tr : 'English'.tr,
                style: const TextStyle(color: Color(0xFF0E54EB)),
              ),
              onTap: () {
                Get.defaultDialog(
                  title: 'Select language'.tr,
                  content: Column(
                    children: [
                      ListTile(
                        title: Text('English'.tr),
                        onTap: () {
                          Get.updateLocale(const Locale('en', 'US'));
                          Get.back();
                        },
                      ),
                      ListTile(
                        title: Text('Khmer'.tr),
                        onTap: () {
                          Get.updateLocale(const Locale('km', 'KH'));
                          Get.back();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Connection
            ListTile(
              leading: const Icon(Icons.wifi),
              title: Text("Connection".tr),
              trailing: Text(
                "Online".tr,
                style: const TextStyle(color: Color(0xFF0E54EB)),
              ),
              onTap: () {},
            ),

            const Spacer(),

            // Logout
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                "Logout".tr,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                authController.logout();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          const HomeScreen(),
          PostScreen(),
          const UserScreen(),
          const SettingScreen()
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        indicatorColor: const Color(0xFF0E54EB).withValues(alpha: 0.2),
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'Home'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article),
            label: 'Post'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_2_outlined),
            selectedIcon: const Icon(Icons.person),
            label: 'User'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'Setting'.tr,
          ),
        ],
      ),
      floatingActionButton: (currentIndex == 1 || currentIndex == 2)
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0E54EB),
              foregroundColor: Colors.white,
              onPressed: () {
                if (currentIndex == 1) {
                  Get.to(() => const CreatePostScreen());
                } else if (currentIndex == 2) {
                  Get.to(() => const CreateUserScreen());
                }
              },
              icon: const Icon(
                Icons.add,
                color: Colors.black87,
              ),
              label: Text(
                (currentIndex == 1 ? 'New post' : 'New user').tr,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            )
          : null,
    );
  }
}
