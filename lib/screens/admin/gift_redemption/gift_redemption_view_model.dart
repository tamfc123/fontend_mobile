import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/models/student_redemption_model.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_redemption_repository.dart';

class GiftRedemptionViewModel extends ChangeNotifier {
  final AdminUserRepository _userRepository;
  final AdminGiftRedemptionRepository _redemptionRepository;

  GiftRedemptionViewModel(this._userRepository, this._redemptionRepository);

  // Student list state
  List<UserModel> _students = [];
  bool _isLoadingStudents = false;
  String _searchQuery = '';
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _pageSize = 5;

  // Selected student and redemptions
  UserModel? _selectedStudent;
  List<StudentRedemptionModel> _redemptions = [];
  bool _isLoadingRedemptions = false;

  // Getters
  List<UserModel> get students => _students;
  bool get isLoadingStudents => _isLoadingStudents;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  int get pageSize => _pageSize;

  UserModel? get selectedStudent => _selectedStudent;
  List<StudentRedemptionModel> get redemptions => _redemptions;
  bool get isLoadingRedemptions => _isLoadingRedemptions;

  /// Fetch students with pagination using AdminUserRepository
  Future<void> fetchStudents({int page = 1}) async {
    _isLoadingStudents = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userRepository.getUserPaged(
        page: page,
        pageSize: _pageSize,
        search: _searchQuery,
        role: 'student', // Only get students
      );

      _students = result['data'] as List<UserModel>;
      _totalCount = result['totalItems'] as int;
      _currentPage = result['page'] as int;
      _totalPages = result['totalPages'] as int;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error fetching students: $e');
      _errorMessage = e.toString();
      _students = [];
    } finally {
      _isLoadingStudents = false;
      notifyListeners();
    }
  }

  /// Search students
  Future<void> searchStudents(String query) async {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page when searching
    await fetchStudents(page: 1);
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages) return;
    await fetchStudents(page: page);
  }

  /// Select a student and load their redemptions
  Future<void> selectStudent(UserModel student) async {
    _selectedStudent = student;
    notifyListeners();
    await loadRedemptions(student.id);
  }

  /// Load redemption history for selected student
  Future<void> loadRedemptions(String userId) async {
    _isLoadingRedemptions = true;
    notifyListeners();

    try {
      _redemptions = await _redemptionRepository.getUserRedemptions(userId);
    } catch (e) {
      debugPrint('Error loading redemptions: $e');
      _redemptions = [];
    } finally {
      _isLoadingRedemptions = false;
      notifyListeners();
    }
  }

  /// Confirm delivery
  Future<bool> confirmDelivery(String redemptionId) async {
    try {
      await _redemptionRepository.confirmRedemption(redemptionId);
      // Reload redemptions after confirmation
      if (_selectedStudent != null) {
        await loadRedemptions(_selectedStudent!.id);
      }
      return true;
    } catch (e) {
      debugPrint('Error confirming delivery: $e');
      return false;
    }
  }
}
