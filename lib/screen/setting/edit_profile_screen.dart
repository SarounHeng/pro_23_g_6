import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/controller/auth_controller.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    void showImageSourceSheet() {
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, size: 28),
                title:  Text('Choose from gallery'.tr, style: const TextStyle(fontSize: 18)),
                onTap: () {
                  Get.back();
                  controller.pickProfileImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, size: 28),
                title:  Text('Take a photo'.tr, style: const TextStyle(fontSize: 18)),
                onTap: () {
                  Get.back();
                  controller.pickProfileImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Edit user'.tr,
          style: const TextStyle(
            color: Color(0xff172033),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E54EB).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              image: controller.profileImage.value != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(controller
                                              .profileImage.value!.path)
                                          : FileImage(File(controller
                                                  .profileImage.value!.path))
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : (controller.currentUserImageUrl.value.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            Get.find<ApiService>()
                                                .resolveImageUrl(controller
                                                    .currentUserImageUrl.value),
                                            headers: Get.find<ApiService>()
                                                        .token !=
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
                            child: controller.profileImage.value == null &&
                                    controller.currentUserImageUrl.value.isEmpty
                                ? Center(
                                    child: Text(
                                      controller.currentUserNickname.value
                                          .substring(0, 2)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF0E54EB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                  )
                                : null,
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: showImageSourceSheet,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0E54EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                   Text(
                    'Tap to replace the photo'.tr,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Username (email) Field
             Text(
              'Username (email)'.tr,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.editEmailController,
              decoration: InputDecoration(
                hintText: 'admin@example.com'.tr,
                prefixIcon: const Icon(Icons.mail_outline, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0E54EB)),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Nickname Field
             Text(
              'Nickname'.tr,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.editNicknameController,
              decoration: InputDecoration(
                hintText: 'Admin'.tr,
                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0E54EB)),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isUpdating.value
                        ? null
                        : () => controller.updateProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E54EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isUpdating.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        :  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Update'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  )),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
