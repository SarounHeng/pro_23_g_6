import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/repository/auth_repository.dart';
import 'package:pro_23_g_6/screen/auth/login_screen.dart';
import 'package:pro_23_g_6/screen/main_screen.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final isLoading = false.obs;

  // Login controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final tokenInputController = TextEditingController();

  // Register controllers
  final nameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();

  // Profile data
  final currentUserId = 0.obs;
  final currentUserName = "Admin".obs;
  final currentUserEmail = "admin@example.com".obs;
  final currentUserNickname = "Admin".obs;
  final currentUserImageUrl = "".obs;
  final profileImage = Rxn<XFile>();

  // Edit profile controllers
  final editEmailController = TextEditingController();
  final editNicknameController = TextEditingController();
  final isUpdating = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill login fields with your credentials
    emailController.text = "Saroun123@example.com";
    passwordController.text = "Saroun@123";

    // Initialize edit controllers with current data
    editEmailController.text = currentUserEmail.value;
    editNicknameController.text = currentUserNickname.value;
    
    // Fetch real profile data immediately
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _authRepository.getProfile();
      debugPrint("Fetch Profile Response: ${response.statusCode} - ${response.body}");
      
      if (response.status.isOk && response.body != null) {
        final data = response.body['data'];
        if (data != null) {
          currentUserId.value = data['id'] ?? 0;
          currentUserName.value = data['username'] ?? data['nickName'] ?? "User";
          currentUserEmail.value = data['email'] ?? "";
          currentUserNickname.value = data['nickName'] ?? data['username'] ?? "";
          currentUserImageUrl.value = data['imageUrl'] ?? "";
          
          // Update edit controllers
          editEmailController.text = currentUserEmail.value;
          editNicknameController.text = currentUserNickname.value;
        } else {
          debugPrint("Profile data is null in response");
        }
      } else {
        debugPrint("Failed to fetch profile: ${response.statusText}");
      }
    } catch (e) {
      debugPrint("Error fetching profile exception: $e");
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImage.value = image;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  Future<void> updateProfile() async {
    if (editEmailController.text.isEmpty || editNicknameController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isUpdating.value = true;
    
    final response = await _authRepository.updateProfile(
      editEmailController.text,
      editNicknameController.text,
    );

    if (response.status.isOk) {
      // Step 2: Upload Image if selected
      if (profileImage.value != null && currentUserId.value != 0) {
        await _authRepository.uploadImage(currentUserId.value, profileImage.value!);
      }

      currentUserEmail.value = editEmailController.text;
      currentUserNickname.value = editNicknameController.text;
      currentUserName.value = editNicknameController.text;

      isUpdating.value = false;
      Get.back();
      Get.snackbar("Success", "Profile updated successfully", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      isUpdating.value = false;
      Get.snackbar("Error", "Failed to update profile: ${response.statusText}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      // First check if there is any internet at all
      final isOnline = await _authRepository.checkConnection();
      if (!isOnline) {
        Get.snackbar(
          "No Internet",
          kIsWeb
              ? "Please check your network connection."
              : "Please check your connection. Try toggling Airplane Mode in emulator.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
        );
        isLoading.value = false;
        return;
      }

      final response = await _authRepository.login(
        emailController.text,
        passwordController.text,
      );
      
      debugPrint("Login Response: ${response.statusCode} - ${response.body}");
      
      if (response.status.isOk) {
        await fetchProfile();
        Get.offAll(() => const MainScreen());
        Get.snackbar("Success".tr, "${"Welcome back".tr}, ${currentUserName.value}!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        String errorMsg = response.statusText ?? "Invalid credentials".tr;
        if (response.body != null && response.body['title'] != null) {
          errorMsg = response.body['title'];
        }
        Get.snackbar("Login Failed".tr, errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error".tr, "No Internet".tr,
          backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 5));
    }
    
    isLoading.value = false;
  }

  Future<void> loginWithToken(String token) async {
    if (token.isEmpty) {
      Get.snackbar("Error".tr, "Please paste a token".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      // Manual JWT Decoding (without external library)
      final parts = token.split('.');
      if (parts.length != 3) throw Exception("Invalid JWT structure");

      String payloadPart = parts[1];
      // Normalize base64
      while (payloadPart.length % 4 != 0) {
        payloadPart += '=';
      }
      
      final String decoded = utf8.decode(base64Url.decode(payloadPart));
      final Map<String, dynamic> payload = json.decode(decoded);
      debugPrint("Decoded JWT Payload: $payload");

      // Extract info (usually 'sub' contains email or username)
      final String email = payload['sub'] ?? payload['email'] ?? "user@example.com";
      final String name = email.contains('@') ? email.split('@')[0] : email;

      // Update State
      _authRepository.updateToken(token);
      currentUserEmail.value = email;
      currentUserName.value = name;
      currentUserNickname.value = name;

      Get.snackbar("Token Login", "Welcome, $name!",
          backgroundColor: const Color(0xFF0E54EB), colorText: Colors.white);
      
      // Try to fetch full profile in background from real endpoint
      await fetchProfile();
      
      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar("Invalid Token", "Could not decode JWT: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void offlineLogin() {
    final String defaultToken = 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJzYXJvdW4xMjNAZXhhbXBsZS5jb20iLCJpYXQiOjE3ODk0NjY1NzMsImV4cCI6MTc4OTU1Mjk3M30.AWghM3iN77YchgGv_xT_9gIuZ0EsaaWQS-kmvO5PiEQJYqkxB_Ev6pdZgdHhS5Qg';
    loginWithToken(defaultToken);
  }

  Future<void> register() async {
    if (nameController.text.isEmpty || 
        registerEmailController.text.isEmpty || 
        registerPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    final response = await _authRepository.register(
      nameController.text,
      registerEmailController.text,
      registerPasswordController.text,
    );
    
    if (response.status.isOk) {
      Get.snackbar("Success", "Account created successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } else {
      Get.snackbar("Registration Failed", response.statusText ?? "Error",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    
    isLoading.value = false;
  }

  void logout() {
    // Clear fields
    emailController.clear();
    passwordController.clear();
    
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    editEmailController.dispose();
    editNicknameController.dispose();
    super.onClose();
  }
}
