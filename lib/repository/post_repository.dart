import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_23_g_6/service/api_service.dart';

class PostRepository {
  final ApiService _api = Get.find<ApiService>();

  Future<Response> getPosts({String? title}) async {
    try {
      return await _api.getPosts(title: title);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> createPost(Map<String, dynamic> data) async {
    try {
      return await _api.createPost(data);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> updatePost(int id, Map<String, dynamic> data) async {
    try {
      return await _api.updatePost(id, data);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> deletePost(int id) async {
    try {
      return await _api.deletePost(id);
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<(bool, String?)> uploadPostImage({required int postId, required XFile imageFile}) async {
    try {
      final response = await _api.uploadPostImage(postId, imageFile);
      if (response.status.isOk) {
        return (true, null);
      } else {
        final body = response.body;
        String errorMsg = "Unknown upload error";
        
        if (body is Map) {
          errorMsg = body['detail'] ?? body['message'] ?? body['error'] ?? response.statusText ?? errorMsg;
        } else {
          errorMsg = response.statusText ?? errorMsg;
        }
        
        return (false, errorMsg.toString());
      }
    } catch (e) {
      return (false, e.toString());
    }
  }
}
