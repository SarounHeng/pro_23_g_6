import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/controller/user_controller.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

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
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, size: 28),
                title:  Text('Take a photo'.tr, style: const TextStyle(fontSize: 18)),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
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
          'New user'.tr,
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
            // Avatar Section
            Center(
              child: GestureDetector(
                onTap: showImageSourceSheet,
                child: Stack(
                  children: [
                    Obx(() => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E54EB).withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            image: controller.selectedImage.value != null
                                ? DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(controller
                                            .selectedImage.value!.path)
                                        : FileImage(File(controller
                                                .selectedImage.value!.path))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.selectedImage.value == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFF0E54EB),
                                )
                              : null,
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0E54EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
             Center(
              child: Text(
                'Photo uploads after the user is created'.tr,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Username Field
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
              controller: controller.usernameController,
              decoration: InputDecoration(
                hintText: 'student@example.com'.tr,
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
            const SizedBox(height: 20),

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
              controller: controller.nicknameController,
              decoration: InputDecoration(
                hintText: 'The server generates one if y...'.tr,
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
            const SizedBox(height: 20),

            // Password Field
             Text(
              'Password'.tr,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => TextField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Student@123'.tr,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                  },
                ),
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
            )),
            const SizedBox(height: 40),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isCreating.value
                        ? null
                        : () => controller.createUser(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E54EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isCreating.value
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
                                'Create user'.tr,
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
