import 'package:get/get.dart';

class PostDataModel {
  static const String baseUrl = 'https://api.example.com'; // Replace with your actual URL

  int? status;
  String? title;
  int? timestamp;
  Pagination? pagination;
  List<Data>? data;

  PostDataModel({
    this.status,
    this.title,
    this.timestamp,
    this.pagination,
    this.data,
  });

  static Future<PostDataModel?> pull({String? title}) async {
    final connect = GetConnect();
    String url = '$baseUrl/posts';
    if (title != null && title.isNotEmpty) {
      url += '?title=$title';
    }
    final response = await connect.get(url);
    if (response.status.hasError) {
      return null;
    }
    return PostDataModel.fromJson(response.body);
  }

  static Future<Response> create(Map<String, dynamic> data, {String? imagePath}) async {
    final connect = GetConnect();
    
    // Use FormData for multipart requests (required for file uploads)
    final formData = FormData(data);
    
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'image', // The field name your API expects for the file
        MultipartFile(imagePath, filename: 'upload.jpg'),
      ));
    }

    return await connect.post('$baseUrl/posts', formData);
  }


  PostDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    title = json['title'];
    timestamp = json['timestamp'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['title'] = title;
    data['timestamp'] = timestamp;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? size;
  int? total;
  int? totalPages;

  Pagination({this.page, this.size, this.total, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    size = json['size'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['size'] = size;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? content;
  String? imageName;
  String? imageUrl;
  bool? published;
  Author? author;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.title,
    this.content,
    this.imageName,
    this.imageUrl,
    this.published,
    this.author,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    imageName = json['imageName'];
    imageUrl = json['imageUrl'];
    published = json['published'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['imageName'] = imageName;
    data['imageUrl'] = imageUrl;
    data['published'] = published;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Author {
  int? id;
  String? username;
  String? nickName;
  String? imageUrl;

  Author({this.id, this.username, this.nickName, this.imageUrl});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    nickName = json['nickName'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['nickName'] = nickName;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
