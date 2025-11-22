// file: data/models/vocabulary_model.dart

// Model để nhận dữ liệu Vocabulary (khớp VocabularyDTO)
class VocabularyModel {
  final String id;
  final String lessonId;
  final String referenceText;
  final String? meaning;
  final String? phonetic;
  final String? sampleAudioUrl; // ⬅️ Link Cloudinary

  VocabularyModel({
    required this.id,
    required this.lessonId,
    required this.referenceText,
    this.meaning,
    this.phonetic,
    this.sampleAudioUrl,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'],
      lessonId: json['lessonId'],
      referenceText: json['referenceText'],
      meaning: json['meaning'],
      phonetic: json['phonetic'],
      sampleAudioUrl: json['sampleAudioUrl'],
    );
  }
}

// Model để gửi đi khi TẠO/SỬA (khớp VocabularyModifyDTO)
class VocabularyModifyModel {
  final String lessonId;
  final String referenceText;
  final String? meaning;
  final String? phonetic;
  final String? sampleAudioUrl;

  VocabularyModifyModel({
    required this.lessonId,
    required this.referenceText,
    this.meaning,
    this.phonetic,
    this.sampleAudioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'referenceText': referenceText,
      'meaning': meaning,
      'phonetic': phonetic,
      'sampleAudioUrl': sampleAudioUrl,
    };
  }
}
