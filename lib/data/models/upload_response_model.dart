class UploadResponse {
  final String? url;
  final String? publicId;
  final String? fileName;
  final String? fileType;

  UploadResponse({this.url, this.publicId, this.fileName, this.fileType});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      url: json['url']?.toString(),
      publicId: json['publicId']?.toString(),
      fileName: json['fileName']?.toString(),
      fileType: json['fileType']?.toString(),
    );
  }
}
