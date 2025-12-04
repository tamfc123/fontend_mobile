import 'package:flutter/material.dart';

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

class PronunciationResultModel {
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final String phoneticWord;
  final int newStrength;
  final int newStreak;
  final int expGained;
  final int coinsGained;
  final List<WordResultModel> wordResults;

  PronunciationResultModel({
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.phoneticWord,
    required this.newStrength,
    required this.wordResults,
    required this.newStreak,
    required this.expGained,
    required this.coinsGained,
  });

  factory PronunciationResultModel.fromJson(Map<String, dynamic> json) {
    var wordList = json['wordResults'] as List? ?? [];
    List<WordResultModel> words =
        wordList.map((w) => WordResultModel.fromJson(w)).toList();

    return PronunciationResultModel(
      accuracyScore: (json['accuracyScore'] as num? ?? 0.0).toDouble(),
      fluencyScore: (json['fluencyScore'] as num? ?? 0.0).toDouble(),
      completenessScore: (json['completenessScore'] as num? ?? 0.0).toDouble(),
      phoneticWord: json['phoneticWord'] ?? '',
      newStrength: json['newStrength'] as int? ?? 0,
      wordResults: words,
      newStreak: (json['newStreak'] as int?) ?? 0,
      expGained: json['expGained'] as int? ?? 0,
      coinsGained: json['coinsGained'] as int? ?? 0,
    );
  }
}

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
      phoneme: json['phoneme'] ?? '',
      accuracyScore: (json['accuracyScore'] as num? ?? 0.0).toDouble(),
      errorType: json['errorType'] ?? 'None',
    );
  }

  Color get color {
    // 1. Nếu API báo lỗi cụ thể -> Màu lỗi
    if (errorType == 'Mispronunciation') {
      return Colors.orange.shade700;
    }
    if (errorType == 'Omission' || errorType == 'Insertion') {
      return Colors.red.shade700;
    }

    // 2. Nếu API báo "None" (Không lỗi), phải check tiếp ĐIỂM SỐ
    // Azure có thể trả về None nhưng điểm thấp (phát âm chưa chuẩn hẳn)
    if (accuracyScore >= 80) {
      return Colors.green.shade700; // Tốt (Xanh)
    } else if (accuracyScore >= 60) {
      return Colors.orange.shade700; // Tạm được (Cam)
    } else {
      return Colors.red.shade700; // Tệ (Đỏ)
    }
  }
}
