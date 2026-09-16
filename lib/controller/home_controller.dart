import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/model/post_data_model.dart';
import 'package:pro_23_g_6/model/slider_model.dart';
import 'package:pro_23_g_6/model/user_data_model.dart';
import 'package:pro_23_g_6/repository/post_repository.dart';
import 'package:pro_23_g_6/repository/user_repository.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  
  final banners = <SliderModel>[].obs;
  final postData = Rxn<PostDataModel>();
  final userData = Rxn<UserDataModel>();
  final isLoading = false.obs;

  // Banner Animation
  final bannerPageController = PageController();
  final currentBannerIndex = 0.obs;
  Timer? _bannerTimer;

  @override
  void onInit() {
    super.onInit();
    loadHome();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (banners.isNotEmpty) {
        if (currentBannerIndex.value < banners.length - 1) {
          currentBannerIndex.value++;
        } else {
          currentBannerIndex.value = 0;
        }

        if (bannerPageController.hasClients) {
          bannerPageController.animateToPage(
            currentBannerIndex.value,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    await loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    try {
      banners.assignAll(_fetchBanners());
      
      // Fetch Posts
      final postRes = await _postRepository.getPosts();
      if (postRes.status.isOk) {
        postData.value = PostDataModel.fromJson(postRes.body);
      }

      // Fetch Users for Home Screen (Limit to 10)
      final userRes = await _userRepository.getUsers(size: 10);
      if (userRes.status.isOk) {
        userData.value = UserDataModel.fromJson(userRes.body);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<SliderModel> _fetchBanners() {
    return <SliderModel>[
      SliderModel(
        title: 'Welcome to GetX Basic',
        subtitle: 'Learn Flutter with GetX',
        imageUrl: 'https://picsum.photos/800/400?random=1',
      ),
      SliderModel(
        title: 'Flutter Development',
        subtitle: 'Build modern mobile applications',
        imageUrl: 'https://picsum.photos/800/400?random=2',
      ),
      SliderModel(
        title: 'GetX State Management',
        subtitle: 'Simple and powerful state management',
        imageUrl: 'https://picsum.photos/800/400?random=3',
      ),
    ];
  }
}
