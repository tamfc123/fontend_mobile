// Model này đại diện cho 1 câu trả lời của sinh viên
class StudentAnswerInputModel {
  final int questionId;
  final int? selectedOptionId; // Dùng cho trắc nghiệm
  final String? answerText; // Dùng cho bài viết/điền từ

  StudentAnswerInputModel({
    required this.questionId,
    this.selectedOptionId,
    this.answerText,
  });

  /// Chuyển đổi model này sang JSON để gửi cho API
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
      'answerText': answerText,
    };
  }
}
