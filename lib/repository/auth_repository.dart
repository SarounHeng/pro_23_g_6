import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();

  void updateToken(String? token) {
    _apiService.updateToken(token);
  }

  Future<bool> checkConnection() async {
    return await _apiService.checkInternet();
  }

  Future<Response> login(String username, String password) async {
    try {
      final response = await _apiService.login({
        'username': username,
        'password': password,
      });
      if (response.status.isOk && response.body != null) {
        final data = response.body['data'];
        final token = data != null ? data['token'] : null;
        if (token != null) {
          _apiService.updateToken(token);
        }
      }
      return response;
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> register(String username, String email, String password) async {
    try {
      return await _apiService.register({
        'username': username,
        'email': email,
        'password': password,
      });
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> getProfile() async {
    try {
      return await _apiService.getProfile();
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> updateProfile(String email, String nickname) async {
    try {
      return await _apiService.updateProfile({
        'email': email,
        'nickname': nickname,
      });
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> uploadImage(int id, XFile imageFile) async {
    try {
      return await _apiService.uploadUserImage(id, imageFile);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }
}
