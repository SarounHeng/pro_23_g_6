import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/controller/home_controller.dart';
import 'package:pro_23_g_6/model/post_data_model.dart';
import 'package:pro_23_g_6/repository/post_repository.dart';

class PostController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  final postData = Rxn<PostDataModel>();
  final isLoading = false.obs;

  // New Post Fields
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final isPublished = true.obs;
  final isCreating = false.obs;
  final isUpdating = false.obs;
  final selectedImage = Rxn<XFile>();
  
  // Edit Mode
  final editingPostId = 0.obs;
  
  // Search
  final searchController = TextEditingController();
  final searchText = "".obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    
    // Debounce search to avoid too many API calls
    debounce(searchText, (_) => fetchPosts(showLoading: false), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchPosts({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await _postRepository.getPosts(title: searchText.value);
      debugPrint("Fetch Posts Response: ${response.statusCode} - ${response.body}");
      if (response.status.isOk) {
        postData.value = PostDataModel.fromJson(response.body);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchPosts();
  }

  Future<void> createPost() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar("Required".tr, "Please enter a post title".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    isCreating.value = true;
    try {
      debugPrint("Creating post: ${titleController.text}");
      final response = await _postRepository.createPost({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'published': isPublished.value,
      });

      debugPrint("Create Post Status: ${response.statusCode}");
      debugPrint("Create Post Body: ${response.body}");

      if (response.status.isOk) {
        // Step 1: Extract Post ID from response
        dynamic newPostId;
        final body = response.body;
        
        if (body is Map) {
          if (body['data'] != null && body['data']['id'] != null) {
            newPostId = body['data']['id'];
          } else if (body['id'] != null) {
            newPostId = body['id'];
          }
        }
        
        debugPrint("Extracted Post ID: $newPostId");

        // Step 2: Upload Image if one was selected
        if (selectedImage.value != null && newPostId != null) {
          final int? id = int.tryParse(newPostId.toString());
          
          if (id != null && id > 0) {
            debugPrint("Starting image upload for Post ID: $id...");
            final (success, error) = await _postRepository.uploadPostImage(
              postId: id,
              imageFile: selectedImage.value!,
            );

            if (!success) {
              debugPrint("Image upload failed: $error");
              Get.snackbar("Image Upload Error".tr, "${"Post created, but image failed".tr}: $error",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 7));
            } else {
              debugPrint("Image upload successful!");
            }
          } else {
            debugPrint("Invalid Post ID format: $newPostId");
          }
        }

        // Step 3: Cleanup and Refresh
        titleController.clear();
        contentController.clear();
        selectedImage.value = null;
        isPublished.value = true;

        // Give server extra time to process image and update DB before refreshing
        await Future.delayed(const Duration(milliseconds: 1500));
        await fetchPosts(showLoading: false);
        
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().onRefresh();
        }

        Get.back(); // Return to previous screen
        Get.snackbar("Success".tr, "Post created successfully".tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
            
      } else {
        final errorMsg = response.body?['message'] ?? response.statusText ?? "Failed to create post".tr;
        Get.snackbar("${"Error".tr} (${response.statusCode})", errorMsg.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Create Post Exception: $e");
      Get.snackbar("Error".tr, "${"An unexpected error occurred".tr}: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isCreating.value = false;
    }
  }

  void prepareEdit(Data post) {
    editingPostId.value = post.id ?? 0;
    titleController.text = post.title ?? "";
    contentController.text = post.content ?? "";
    isPublished.value = post.published ?? true;
    selectedImage.value = null; // Don't show old image as "selected" for replacement yet
  }

  Future<void> updatePost() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar("Required".tr, "Please enter a post title".tr, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isUpdating.value = true;
    try {
      final response = await _postRepository.updatePost(editingPostId.value, {
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'published': isPublished.value,
      });

      if (response.status.isOk) {
        // Handle image if selected
        if (selectedImage.value != null) {
          final (success, error) = await _postRepository.uploadPostImage(
            postId: editingPostId.value,
            imageFile: selectedImage.value!,
          );
          if (!success) {
             Get.snackbar("Image Upload Error".tr, "${"Post updated, but image failed".tr}: $error",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                duration: const Duration(seconds: 7));
          }
        }

        Get.back();
        Get.snackbar("Success".tr, "Post updated successfully".tr, backgroundColor: Colors.green, colorText: Colors.white);
        await Future.delayed(const Duration(milliseconds: 1000));
        fetchPosts();
      } else {
        Get.snackbar("Error".tr, (response.statusText ?? "Failed to update post".tr), backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> togglePublish(Data post) async {
    final newStatus = !(post.published ?? false);
    final response = await _postRepository.updatePost(post.id!, {
      'title': post.title,
      'content': post.content,
      'published': newStatus,
    });

    if (response.status.isOk) {
      Get.snackbar("Success".tr, newStatus ? "Post published".tr : "Post unpublished".tr, backgroundColor: const Color(0xFF0E54EB), colorText: Colors.white);
      fetchPosts(showLoading: false);
    }
  }

  Future<void> deletePost(int id) async {
    Get.defaultDialog(
      title: "Delete Post".tr,
      middleText: "Are you sure you want to delete this post?".tr,
      textConfirm: "Delete".tr,
      textCancel: "Cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        final response = await _postRepository.deletePost(id);
        if (response.status.isOk) {
          Get.snackbar("Delete".tr, "Post has been removed".tr, backgroundColor: Colors.redAccent, colorText: Colors.white);
          fetchPosts(showLoading: false);
        } else {
          Get.snackbar("Error".tr, "Failed to delete post".tr, backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
