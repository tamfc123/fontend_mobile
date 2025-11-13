import 'package:flutter/material.dart';

// ✅ TẠO CLASS MỚI NÀY
class WordResultModel {
  final String word;
  final double accuracyScore;
  final List<PhonemeResultModel> phonemeResults;

  WordResultModel({
    required this.word,
    required this.accuracyScore,
    required this.phonemeResults,
  });

  factory WordResultModel.fromJson(Map<String, dynamic> json) {
    // Lấy danh sách phoneme con (thêm ? để an toàn)
    var phonemesList = json['phonemeResults'] as List? ?? [];
    List<PhonemeResultModel> phonemes =
        phonemesList.map((p) => PhonemeResultModel.fromJson(p)).toList();

    return WordResultModel(
      word: json['word'] ?? '',
      accuracyScore: (json['accuracyScore'] as num? ?? 0.0).toDouble(),
      phonemeResults: phonemes,
    );
  }
}

// ✅ CẬP NHẬT CLASS NÀY
class PronunciationResultModel {
  final double accuracyScore;
  final double fluencyScore; // Giữ nguyên
  final double completenessScore; // Giữ nguyên
  final String phoneticWord;
  final int newStrength;
  final int newStreak;

  // 👇 THAY ĐỔI DÒNG NÀY
  final List<WordResultModel>
  wordResults; // <-- Đổi từ List<PhonemeResultModel>

  PronunciationResultModel({
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.phoneticWord,
    required this.newStrength,
    required this.wordResults, // <-- Sửa ở đây
    required this.newStreak,
  });

  factory PronunciationResultModel.fromJson(Map<String, dynamic> json) {
    // 👇 THAY ĐỔI KHỐI NÀY
    // Lấy danh sách từ (thêm ? để an toàn)
    var wordList = json['wordResults'] as List? ?? [];
    List<WordResultModel> words =
        wordList.map((w) => WordResultModel.fromJson(w)).toList();
    // KẾT THÚC THAY ĐỔI

    return PronunciationResultModel(
      // Thêm ? để an toàn, phòng khi API không trả về
      accuracyScore: (json['accuracyScore'] as num? ?? 0.0).toDouble(),
      fluencyScore: (json['fluencyScore'] as num? ?? 0.0).toDouble(),
      completenessScore: (json['completenessScore'] as num? ?? 0.0).toDouble(),
      phoneticWord: json['phoneticWord'] ?? '',
      newStrength: json['newStrength'] as int? ?? 0,
      wordResults: words, // <-- Sửa ở đây
      newStreak: (json['newStreak'] as int?) ?? 0,
    );
  }
}

// ✅ GIỮ NGUYÊN CLASS NÀY (Chỉ thêm ? để an toàn hơn)
class PhonemeResultModel {
  final String phoneme;
  final double accuracyScore;
  final String errorType;

  PhonemeResultModel({
    required this.phoneme,
    required this.accuracyScore,
    required this.errorType,
  });

  factory PhonemeResultModel.fromJson(Map<String, dynamic> json) {
    return PhonemeResultModel(
      phoneme: json['phoneme'] ?? '', // Thêm ?? ''
      accuracyScore:
          (json['accuracyScore'] as num? ?? 0.0).toDouble(), // Thêm ?
      errorType: json['errorType'] ?? 'None', // Thêm ?? 'None'
    );
  }

  // Helper để lấy màu dựa trên lỗi
  Color get color {
    if (errorType == 'None') return Colors.green.shade700;
    if (errorType == 'Mispronunciation') return Colors.orange.shade700;
    return Colors.red.shade700; // Omission, Insertion...
  }
}
