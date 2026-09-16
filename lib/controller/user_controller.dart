import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/model/user_data_model.dart';
import 'package:pro_23_g_6/repository/user_repository.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final userData = Rxn<UserDataModel>();
  final isLoading = false.obs;
  final searchText = "".obs;
  final searchController = TextEditingController();

  // Form controllers for new user
  final usernameController = TextEditingController();
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isCreating = false.obs;
  final selectedImage = Rxn<XFile>();

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
    fetchUsers();
    debounce(searchText, (_) => fetchUsers(showLoading: false), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchUsers({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    
    final response = await _userRepository.getUsers(query: searchText.value);
    if (response.status.isOk) {
      userData.value = UserDataModel.fromJson(response.body);
    }

    if (showLoading) {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchUsers();
  }

  Future<void> createUser() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error".tr, "${"Username".tr} and ${"Password".tr} ${"are required".tr}", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isCreating.value = true;
    
    final response = await _userRepository.createUser({
      'username': usernameController.text,
      'nickname': nicknameController.text,
      'password': passwordController.text,
    });

    if (response.status.isOk) {
      final data = response.body['data'];
      final newUserId = data != null ? data['id'] : null;
      debugPrint("User created with ID: $newUserId");

      // Step 2: Upload Image if selected
      if (selectedImage.value != null && newUserId != null) {
        debugPrint("Uploading avatar for user $newUserId...");
        final uploadResponse = await _userRepository.uploadImage(newUserId, selectedImage.value!);
        if (!uploadResponse.status.isOk) {
          debugPrint("Avatar upload failed: ${uploadResponse.statusText}");
          Get.snackbar("Warning", "User created but photo upload failed",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white);
        } else {
          debugPrint("Avatar upload successful");
        }
      }

      usernameController.clear();
      nicknameController.clear();
      passwordController.clear();
      selectedImage.value = null;
      isCreating.value = false;
      
      Get.back();
      Get.snackbar("Success", "User created successfully", backgroundColor: Colors.green, colorText: Colors.white);
      
      // Add a small delay before fetching to allow server processing
      await Future.delayed(const Duration(milliseconds: 500));
      fetchUsers();
    } else {
      isCreating.value = false;
      Get.snackbar("Error", "Failed to create user: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    usernameController.dispose();
    nicknameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
