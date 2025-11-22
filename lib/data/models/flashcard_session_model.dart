// lib/data/models/flashcard_session_model.dart

// Khớp với FlashcardItemDTO
class FlashcardItemModel {
  final String vocabularyId;
  final String referenceText;
  final String? meaning;
  final String? phonetic;
  final String? sampleAudioUrl;
  int currentStrength; // Có thể thay đổi trên UI
  final String? lastPronunciationJson;

  FlashcardItemModel({
    required this.vocabularyId,
    required this.referenceText,
    this.meaning,
    this.phonetic,
    this.sampleAudioUrl,
    required this.currentStrength,
    this.lastPronunciationJson,
  });

  factory FlashcardItemModel.fromJson(Map<String, dynamic> json) {
    return FlashcardItemModel(
      vocabularyId: json['vocabularyId'],
      referenceText: json['referenceText'],
      meaning: json['meaning'],
      phonetic: json['phonetic'],
      sampleAudioUrl: json['sampleAudioUrl'],
      currentStrength: json['currentStrength'],
      lastPronunciationJson: json['lastPronunciationJson'],
    );
  }
}

// Khớp với FlashcardSessionDTO
class FlashcardSessionModel {
  final String lessonId;
  final String lessonTitle;
  final List<FlashcardItemModel> flashcards;

  FlashcardSessionModel({
    required this.lessonId,
    required this.lessonTitle,
    required this.flashcards,
  });

  factory FlashcardSessionModel.fromJson(Map<String, dynamic> json) {
    var list = json['flashcards'] as List;
    List<FlashcardItemModel> flashcardsList =
        list.map((i) => FlashcardItemModel.fromJson(i)).toList();

    return FlashcardSessionModel(
      lessonId: json['lessonId'],
      lessonTitle: json['lessonTitle'],
      flashcards: flashcardsList,
    );
  }
}
