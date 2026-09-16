
class UserDataModel {
  static const String baseUrl = 'https://api.example.com'; 

  int? status;
  String? title;
  int? timestamp;
  Pagination? pagination;
  List<User>? data;

  UserDataModel({
    this.status,
    this.title,
    this.timestamp,
    this.pagination,
    this.data,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    title = json['title'];
    timestamp = json['timestamp'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <User>[];
      json['data'].forEach((v) {
        data!.add(User.fromJson(v));
      });
    }
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
}

class User {
  int? id;
  String? username;
  String? nickName;
  String? email;
  String? imageName;
  String? imageUrl;
  String? createdAt;

  User({
    this.id,
    this.username,
    this.nickName,
    this.email,
    this.imageName,
    this.imageUrl,
    this.createdAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    nickName = json['nickName'];
    email = json['email'];
    imageName = json['imageName'];
    imageUrl = json['imageUrl'];
    createdAt = json['createdAt'];
  }
}
