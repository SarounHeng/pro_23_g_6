import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class UserRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Response> getUsers({String? query, int? page, int? size}) async {
    try {
      return await _apiService.getUsers(query: query, page: page, size: size);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> createUser(Map<String, dynamic> data) async {
    try {
      return await _apiService.createUser(data);
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
