import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/home_controller.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for Home Data
    final homeController = Get.find<HomeController>();

    return Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => homeController.onRefresh(),
          color: const Color(0xFF0E54EB),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Banner Slider Section
              if (homeController.banners.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PageView.builder(
                        controller: homeController.bannerPageController,
                        onPageChanged: (index) {
                          homeController.currentBannerIndex.value = index;
                        },
                        itemCount: homeController.banners.length,
                        itemBuilder: (context, index) {
                          final banner = homeController.banners[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      Get.find<ApiService>()
                                          .resolveImageUrl(banner.imageUrl),
                                      headers: Get.find<ApiService>().token !=
                                              null
                                          ? {
                                              'Authorization':
                                                  'Bearer ${Get.find<ApiService>().token}'
                                            }
                                          : null,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFF0E54EB).withValues(alpha: 0.3),
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Gradient Overlay and Content
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(alpha: 0.1),
                                          Colors.black.withValues(alpha: 0.7),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          banner.title.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          banner.subtitle?.tr ?? '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dots Indicator
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            homeController.banners.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: homeController.currentBannerIndex.value ==
                                      index
                                  ? 24
                                  : 8,
                              decoration: BoxDecoration(
                                color: homeController.currentBannerIndex.value ==
                                        index
                                    ? const Color(0xFF0E54EB)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),

              const SizedBox(height: 24),

              // Users Section
              if (homeController.userData.value?.data != null && homeController.userData.value!.data!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Users'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homeController.userData.value!.data!.length,
                        itemBuilder: (context, index) {
                          final user = homeController.userData.value!.data![index];
                          final initials = (user.username != null && user.username!.isNotEmpty) 
                              ? user.username!.substring(0, 1).toUpperCase() 
                              : "?";
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 70,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFF0E54EB).withValues(alpha: 0.1),
                                  backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                                      ? NetworkImage(
                                          Get.find<ApiService>().resolveImageUrl(user.imageUrl, fileName: user.imageName),
                                          headers: Get.find<ApiService>().token != null 
                                            ? {'Authorization': 'Bearer ${Get.find<ApiService>().token}'} 
                                            : null,
                                        )
                                      : null,
                                  child: (user.imageUrl == null || user.imageUrl!.isEmpty) 
                                      ? Text(initials, style: const TextStyle(color: Color(0xFF0E54EB), fontWeight: FontWeight.bold)) 
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.nickName ?? user.username ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Latest Posts Title
              Text(
                homeController.postData.value?.title?.tr ?? 'Latest Posts'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Posts List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: homeController.postData.value?.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final post = homeController.postData.value!.data![index];
                  final apiService = Get.find<ApiService>();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: const Color(0xffe8f1f2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: (post.imageUrl != null &&
                                        post.imageUrl!.isNotEmpty) ||
                                    (post.imageName != null &&
                                        post.imageName!.isNotEmpty)
                                ? Image.network(
                                    apiService.resolveImageUrl(post.imageUrl,
                                        fileName: post.imageName),
                                    headers: apiService.token != null
                                        ? {'Authorization': 'Bearer ${apiService.token}'}
                                        : null,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildImagePlaceholder(),
                                  )
                                : _buildImagePlaceholder(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff172033),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${post.author?.nickName ?? 'Unknown'} · ${_formatDate(post.createdAt ?? '')}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImagePlaceholder() {
    return const Icon(
      Icons.article,
      size: 35,
      color: Color(0xFF0E54EB),
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
