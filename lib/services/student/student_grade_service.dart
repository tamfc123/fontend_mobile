import 'package:flutter/material.dart';
import 'package:mobile/data/models/grade_summary_model.dart';
import 'package:mobile/domain/repositories/student_grade_repository.dart';

class StudentGradeService extends ChangeNotifier {
  final StudentGradeRepository _repository;
  StudentGradeService(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  GradeSummaryModel? _summary;
  GradeSummaryModel? get summary => _summary;

  Future<void> fetchGradeSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _repository.getGradeSummary();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
