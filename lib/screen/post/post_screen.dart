import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/post_controller.dart';
import 'package:pro_23_g_6/screen/post/edit_post_screen.dart';
import 'package:pro_23_g_6/service/api_service.dart';
import 'package:pro_23_g_6/model/post_data_model.dart';

class PostScreen extends StatelessWidget {
  PostScreen({super.key});

  final PostController controller = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = controller.postData.value?.data ?? [];
        final pagination = controller.postData.value?.pagination;

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
                    color: const Color(0xFF0E54EB).withValues(alpha: 0.5),
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
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by title'.tr,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                        onChanged: (value) {
                          controller.searchText.value = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Post count
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  '${posts.length} ${'of'.tr} ${pagination?.total ?? posts.length} ${'shown'.tr}',
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= POST LIST =================
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.onRefresh(),
                color: const Color(0xFF0E54EB),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final apiService = Get.find<ApiService>();
                    return postCard(
                      post: post,
                      imageUrl: apiService.resolveImageUrl(post.imageUrl,
                          fileName: post.imageName),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      });
  }

// ================= POST CARD =================

Widget postCard({
  required Data post,
  String? imageUrl,
}) {
  final apiService = Get.find<ApiService>();
  final String title = post.title ?? '';
  final String description = post.content ?? '';
  final String author = post.author?.nickName ?? 'Unknown'.tr;
  final String date = post.createdAt ?? '';
  final bool? isPublished = post.published;

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    constraints: const BoxConstraints(minHeight: 145),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Row(
      children: [
        // Image placeholder
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xffe8f1f2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    headers: apiService.token != null
                        ? {'Authorization': 'Bearer ${apiService.token}'}
                        : null,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("Image Load Error ($imageUrl): $error");
                      return const Icon(
                        Icons.article,
                        size: 40,
                        color: Color(0xFF0E54EB),
                      );
                    },
                  )
                : const Icon(
                    Icons.article,
                    size: 40,
                    color: Color(0xFF0E54EB),
                  ),
          ),
        ),


        const SizedBox(width: 20),

        // Text
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff172033),
                      ),
                    ),
                  ),
                  if (isPublished == false)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Draft'.tr,
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),

              const SizedBox(height: 5),

              Text(
                "$author · ${_formatDate(date)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Three dots
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.blueGrey,
          ),
          onSelected: (value) {
            if (value == 'edit') {
              controller.prepareEdit(post);
              Get.to(() => const EditPostScreen());
            } else if (value == 'publish') {
              controller.togglePublish(post);
            } else if (value == 'delete') {
              controller.deletePost(post.id!);
            }
          },
          itemBuilder: (context) => [
             PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text('Edit'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'publish',
              child: Row(
                children: [
                  Icon(
                    (isPublished ?? false)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text((isPublished ?? false) ? 'Unpublish'.tr : 'Publish'.tr),
                ],
              ),
            ),
             PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Text('Delete'.tr, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
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
