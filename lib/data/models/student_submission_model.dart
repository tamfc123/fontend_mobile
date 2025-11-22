class StudentAnswerInputModel {
  final String questionId;
  final String? selectedOptionId; // Dùng cho trắc nghiệm
  final String? answerText; // Dùng cho bài viết/điền từ

  StudentAnswerInputModel({
    required this.questionId,
    this.selectedOptionId,
    this.answerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
      'answerText': answerText,
    };
  }
}
