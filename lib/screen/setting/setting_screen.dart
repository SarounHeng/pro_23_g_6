import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/auth_controller.dart';
import 'package:pro_23_g_6/screen/setting/edit_profile_screen.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Profile Card
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E54EB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E54EB).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: authController.profileImage.value != null
                              ? DecorationImage(
                                  image: FileImage(File(authController
                                      .profileImage.value!.path)),
                                  fit: BoxFit.cover,
                                )
                              : (authController.currentUserImageUrl.value.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        Get.find<ApiService>()
                                            .resolveImageUrl(authController
                                                .currentUserImageUrl.value),
                                        headers: Get.find<ApiService>().token !=
                                                null
                                            ? {
                                                'Authorization':
                                                    'Bearer ${Get.find<ApiService>().token}'
                                              }
                                            : null,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: authController.profileImage.value == null &&
                                authController.currentUserImageUrl.value.isEmpty
                            ? Center(
                                child: Text(
                                  authController.currentUserName.value
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF0E54EB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "Signed in as".tr,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              authController.currentUserName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authController.currentUserEmail.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 40),

            // YOUR ACCOUNT Section
            _buildSectionHeader("YOUR ACCOUNT"),
            _buildSettingItem(
              icon: Icons.edit_outlined,
              title: "Edit profile",
              subtitle: "Update your name and photo",
              onTap: () {
                Get.to(() => const EditProfileScreen());
              },
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // PREFERENCES Section
            _buildSectionHeader("PREFERENCES"),
            _buildSettingItem(
              icon: Icons.translate_outlined,
              title: "Language",
              subtitle: "Switch between Khmer and English",
              onTap: () {
                _showLanguageDialog();
              },
              trailing: Text(
                Get.locale?.languageCode == 'km' ? 'Khmer'.tr : 'English'.tr,
                style: const TextStyle(
                  color: Color(0xFF0E54EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildSettingItem(
              icon: Icons.wifi_outlined,
              title: "Connection",
              onTap: () {},
              trailing:  Text(
                "Online".tr,
                style: const TextStyle(
                  color: Color(0xFF0E54EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ABOUT Section
            _buildSectionHeader("ABOUT"),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: "Version",
              onTap: () {},
              trailing: const Text(
                "1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => authController.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Logout'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title.tr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff172033),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
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
  }
}
