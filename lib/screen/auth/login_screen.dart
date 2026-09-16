import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_23_g_6/controller/auth_controller.dart';
import 'package:pro_23_g_6/screen/auth/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Icon
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Color(0xFF0E54EB),
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Welcome".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your credentials to login".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Email Field
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    hintText: "Email".tr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password".tr,
                    prefixIcon: const Icon(Icons.password_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value 
                      ? null 
                      : () => controller.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E54EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Login".tr, style: const TextStyle(fontSize: 18)),
                )),
                
                const SizedBox(height: 16),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?".tr),
                    TextButton(
                      onPressed: () => Get.to(() => const RegisterScreen()),
                      child: Text(
                        "Sign Up".tr,
                        style: const TextStyle(color: Color(0xFF0E54EB), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Token Login Section
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  "Login with Token".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.tokenInputController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Paste JWT Token here...".tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.login, color: Color(0xFF0E54EB)),
                      onPressed: () => controller.loginWithToken(controller.tokenInputController.text),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Offline Login Fallback
                TextButton.icon(
                  onPressed: () => controller.offlineLogin(),
                  icon: const Icon(Icons.offline_bolt_outlined, color: Colors.orange),
                  label: Text(
                    "Use Default Token".tr,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
