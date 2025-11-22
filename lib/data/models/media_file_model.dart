class MediaFileModel {
  final String id;
  final String fileName;
  final String url;
  final String publicId;
  final DateTime createdAt;

  MediaFileModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.publicId,
    required this.createdAt,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      publicId: json['publicId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
