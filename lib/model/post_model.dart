class PostModel {
  const PostModel({required this.title, required this.imageUrl, this.author});

  final String title;
  final String imageUrl;
  final UserModel? author;

  String get fullImageUrl => imageUrl;
}

class UserModel {
  const UserModel({required this.displayName});

  final String displayName;
}