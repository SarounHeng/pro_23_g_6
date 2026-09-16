import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/user_controller.dart';
import 'package:pro_23_g_6/model/user_data_model.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = controller.userData.value?.data ?? [];

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xff8de8e0),
                    width: 2.0,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.search,
                      size: 32,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: (v) => controller.searchText.value = v,
                        decoration: InputDecoration(
                          hintText: 'Search by username'.tr,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                          ),
                        ),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // User count
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${users.length} ${'of'.tr} ${controller.userData.value?.pagination?.total ?? users.length} ${'shown'.tr}',
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Text(
                      'live'.tr,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // User List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.onRefresh(),
                color: const Color(0xFF0E54EB),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return userCard(user);
                  },
                ),
              ),
            ),
          ],
        );
      });
  }

  Widget userCard(User user) {
    String initials = "";
    if (user.username != null && user.username!.isNotEmpty) {
      final parts = user.username!.split(' ');
      if (parts.length > 1) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else if (user.username!.length >= 2) {
        initials = user.username!.substring(0, 2).toUpperCase();
      } else {
        initials = user.username![0].toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF0E54EB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              image: (user.imageUrl != null && user.imageUrl!.isNotEmpty) ||
                      (user.imageName != null && user.imageName!.isNotEmpty)
                  ? DecorationImage(
                      image: kIsWeb ||
                              (user.imageUrl != null &&
                                  user.imageUrl!.startsWith('http'))
                          ? NetworkImage(
                              Get.find<ApiService>().resolveImageUrl(
                                  user.imageUrl,
                                  fileName: user.imageName),
                              headers: Get.find<ApiService>().token != null
                                  ? {
                                      'Authorization':
                                          'Bearer ${Get.find<ApiService>().token}'
                                    }
                                  : null,
                            ) as ImageProvider
                          : FileImage(File(user.imageUrl!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (user.imageUrl == null || user.imageUrl!.isEmpty) &&
                    (user.imageName == null || user.imageName!.isEmpty)
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF0E54EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff172033),
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  _formatDate(user.createdAt ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return "${date.day} ${months[date.month - 1].tr} ${date.year}";
  }
}
