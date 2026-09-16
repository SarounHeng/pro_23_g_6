import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/controller/post_controller.dart';

class EditPostScreen extends StatelessWidget {
  const EditPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();

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
        title:  Text(
          'Edit post'.tr,
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
            const SizedBox(height: 10),
            // Image Placeholder
            GestureDetector(
              onTap: showImageSourceSheet,
              child: Obx(() => Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E54EB).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0E54EB).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      image: controller.selectedImage.value != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(
                                      controller.selectedImage.value!.path)
                                  : FileImage(File(
                                          controller.selectedImage.value!.path))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: controller.selectedImage.value == null
                        ?  Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 60,
                                color: Color(0xFF0E54EB),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to change picture'.tr,
                                style: const TextStyle(
                                  color: Color(0xFF0E54EB),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : null,
                  )),
            ),
            const SizedBox(height: 30),

            // Title Field
             Text(
              'Title'.tr,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'Post title'.tr,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(Icons.title, color: Colors.black54),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
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

            // Content Field
             Text(
              'Content'.tr,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write something...'.tr,
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

            // Published Switch
            Row(
              children: [
                 Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Published'.tr,
                        style: const TextStyle(
                          color: Color(0xff172033),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Visible to everyone'.tr,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Switch(
                      value: controller.isPublished.value,
                      onChanged: (value) => controller.isPublished.value = value,
                      activeColor: const Color(0xFF0E54EB),
                    )),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isUpdating.value
                        ? null
                        : () => controller.updatePost(),
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
                              const Icon(Icons.save, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Save Changes'.tr,
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
