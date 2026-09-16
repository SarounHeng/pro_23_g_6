import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/screen/auth/login_screen.dart';

class ApiService extends GetConnect {
  static String _baseUrl = 'https://flutter-api.janrent.com';
  String? _token;

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    
    httpClient.addRequestModifier<dynamic>((request) {
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        Get.snackbar(
          "Session Expired".tr,
          "Your session has ended. Please log in again.".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.offAll(() => const LoginScreen());
      }
      return response;
    });
    
    super.onInit();
  }

  void updateToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  void setBaseUrl(String url) {
    _baseUrl = url;
    httpClient.baseUrl = url;
  }

  String resolveImageUrl(String? url, {String? fileName}) {
    String finalUrl = "";
    
    // Normalize url if it exists
    String? cleanUrlPath = url?.trim();
    String? cleanFileName = fileName?.trim();

    if ((cleanUrlPath == null || cleanUrlPath.isEmpty) && (cleanFileName == null || cleanFileName.isEmpty)) {
      finalUrl = "";
    } else if (cleanUrlPath != null && cleanUrlPath.startsWith('http')) {
      // Prioritize direct URL if it looks like a full URL
      finalUrl = cleanUrlPath;
    } else if ((cleanUrlPath == null || cleanUrlPath.isEmpty || !cleanUrlPath.contains('/')) && 
               (cleanFileName != null && cleanFileName.isNotEmpty)) {
      // If we have a filename but no path, or url looks like just a filename
      finalUrl = '$_baseUrl/api/files/$cleanFileName';
    } else if (cleanUrlPath != null && cleanUrlPath.isNotEmpty) {
      // Handle relative path (e.g. /api/files/...) or filename-only in url
      if (!cleanUrlPath.contains('/')) {
        finalUrl = '$_baseUrl/api/files/$cleanUrlPath';
      } else {
        // Ensure path starts with /
        final String formattedPath = cleanUrlPath.startsWith('/') ? cleanUrlPath : '/$cleanUrlPath';
        
        // If the path already contains the base URL path (e.g. /api/files/...) 
        // but not the full URL, prepend base URL
        finalUrl = '$_baseUrl$formattedPath';
      }
    }

    // Secondary fallback: if finalUrl is still problematic or empty, try the other field
    if ((finalUrl.isEmpty || finalUrl == _baseUrl) && cleanFileName != null && cleanFileName.isNotEmpty) {
       finalUrl = '$_baseUrl/api/files/$cleanFileName';
    }

    if (finalUrl.isNotEmpty) {
      debugPrint("Resolved Image URL: '$finalUrl' (from url: '$url', file: '$fileName')");
    }
    return finalUrl;
  }

  Future<bool> checkInternet() async {
    if (kIsWeb) return true;
    try {
      // Use a fresh GetConnect instance to avoid baseUrl and headers interference
      final standaloneConnect = GetConnect();
      final response = await standaloneConnect
          .get('https://www.google.com')
          .timeout(const Duration(seconds: 5));
      return response.status.hasError == false || response.statusCode != null;
    } catch (_) {
      return false;
    }
  }

  // Auth API
  Future<Response> login(Map<String, dynamic> data) => post('/api/auth/login', data);
  Future<Response> register(Map<String, dynamic> data) => post('/api/auth/register', data);
  Future<Response> getProfile() => get('/api/users/me');

  // Posts API
  Future<Response> getPosts({String? title}) {
    String path = '/api/posts';
    if (title != null && title.isNotEmpty) {
      path += '?title=$title';
    }
    return get(path);
  }

  Future<Response> createPost(Map<String, dynamic> data) =>
      post('/api/posts', data);

  Future<Response> updatePost(int id, Map<String, dynamic> data) =>
      put('/api/posts/$id', data);

  Future<Response> deletePost(int id) =>
      delete('/api/posts/$id');

  Future<Response> uploadPostImage(int id, XFile imageFile) async {
    try {
      debugPrint("ApiService: Reading bytes for post image upload...");
      final bytes = await imageFile.readAsBytes();
      
      final formData = FormData({
        'file': MultipartFile(
          bytes, 
          filename: imageFile.name,
        ),
      });

      debugPrint("ApiService: Sending POST to /api/posts/$id/image");
      final response = await post(
        '/api/posts/$id/image', 
        formData,
        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
      );
      
      debugPrint("ApiService: Upload Response Status: ${response.statusCode}");
      debugPrint("ApiService: Upload Response Body: ${response.body}");
      return response;
    } catch (e) {
      debugPrint("ApiService: Upload Exception: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // Users API
  Future<Response> getUsers({String? query, int? page, int? size}) {
    String path = '/api/users';
    List<String> params = [];
    if (query != null && query.isNotEmpty) params.add('query=$query');
    if (page != null) params.add('page=$page');
    if (size != null) params.add('size=$size');
    
    if (params.isNotEmpty) {
      path += '?' + params.join('&');
    }
    return get(path);
  }

  Future<Response> createUser(Map<String, dynamic> data) =>
      post('/api/users', data);

  Future<Response> uploadUserImage(int id, XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData({
        'file': MultipartFile(
          bytes, 
          filename: imageFile.name,
        ),
      });
      return post(
        '/api/users/$id/image', 
        formData,
        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
      );
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      put('/api/users/profile', data);

  // Generic upload method
  Future<Response> upload(String path, {required String filePath}) async {
    final bytes = await File(filePath).readAsBytes();
    final formData = FormData({
      'file': MultipartFile(bytes, filename: filePath.split('/').last),
    });
    return post(path, formData);
  }
}
