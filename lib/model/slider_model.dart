class SliderModel {
  const SliderModel({
    required this.title,
    this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String? subtitle;
  final String imageUrl;

  String get fullImageUrl => imageUrl;
}