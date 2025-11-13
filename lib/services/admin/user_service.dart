import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/user_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

enum UserRole { all, admin, teacher, student }

enum UserStatus { all, active, blocked }

enum UserSortOption { nameAsc, nameDesc, emailAsc, emailDesc }

class UserService extends ChangeNotifier {
  final UserRepository _userRepository;
  UserService(this._userRepository);

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 1;
  int _totalItems = 0;

  String _searchQuery = '';
  UserRole _roleFilter = UserRole.all;
  UserStatus _statusFilter = UserStatus.all;
  UserSortOption _sortOption = UserSortOption.nameAsc;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole get roleFilter => _roleFilter;
  UserStatus get statusFilter => _statusFilter;
  UserSortOption get sortOption => _sortOption;

  int get totalItems => _totalItems;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;
  // lay user phan trang
  Future<void> fetchUsers({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // ✅ THAY THẾ ApiService BẰNG _userRepository
      final result = await _userRepository.getUserPaged(
        page: page ?? _currentPage,
        pageSize: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        role: _roleFilter != UserRole.all ? _roleFilter.name : null,
        isActive:
            _statusFilter == UserStatus.all
                ? null
                : _statusFilter == UserStatus.active,
        sort: _mapSortOption(_sortOption),
      );

      _users = result["data"];
      _totalItems = result["totalItems"];
      _totalPages = result["totalPages"];
      _currentPage = result["page"];
    } catch (e) {
      _users = [];
      _errorMessage =
          "Lỗi khi tải người dùng: ${e.toString().replaceFirst('Exception: ', '')}";
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Filter / Sort =================
  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchUsers(page: 1);
  }

  void updateRoleFilter(UserRole filter) {
    _roleFilter = filter;
    fetchUsers(page: 1);
  }

  void updateStatusFilter(UserStatus filter) {
    _statusFilter = filter;
    fetchUsers(page: 1);
  }

  void updateSortOption(UserSortOption option) {
    _sortOption = option;
    fetchUsers(page: 1);
  }

  // ================= Helper =================
  String _mapSortOption(UserSortOption option) {
    switch (option) {
      case UserSortOption.nameAsc:
        return "name_asc";
      case UserSortOption.nameDesc:
        return "name_desc";
      case UserSortOption.emailAsc:
        return "email_asc";
      case UserSortOption.emailDesc:
        return "email_desc";
    }
  }

  // ================= Teachers riêng =================
  List<UserModel> _teachers = [];
  List<UserModel> get teachers => _teachers;

  Future<void> fetchTeachers() async {
    try {
      // ✅ THAY THẾ ApiService BẰNG _userRepository
      final result = await _userRepository.getUserPaged(
        page: 1,
        pageSize: 100, // lấy nhiều 1 lần
        role: "teacher",
      );

      _teachers = result["data"];
      notifyListeners();
    } catch (e) {
      _teachers = [];
      // Thông báo lỗi thay vì rethrow
      ToastHelper.showError(
        "Lỗi tải danh sách giáo viên: ${e.toString().replaceFirst('Exception: ', '')}",
      );
      notifyListeners();
    }
  }

  //ham delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // ✅ THAY THẾ ApiService BẰNG _userRepository
      final success = await _userRepository.deleteUser(userId);
      if (success) {
        ToastHelper.showSucess('Xóa tài khoản thành công');
        await fetchUsers(page: _currentPage);
      }
      return success;
    } catch (e) {
      ToastHelper.showError(
        'Xóa tài khoản thất bại: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //ham khoa/mo user
  Future<bool> toggleUserStatus(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // ✅ THAY THẾ ApiService BẰNG _userRepository
      final success = await _userRepository.toggleUserStatus(id);
      if (success) {
        ToastHelper.showSucess("Cập nhật trạng thái thành công!");
        await fetchUsers(page: _currentPage);
        return true;
      }
      return false;
    } catch (e) {
      ToastHelper.showError(
        "Lỗi khi cập nhật trạng thái: ${e.toString().replaceFirst('Exception: ', '')}",
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm user mới (Admin)
  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null; // Xóa lỗi cũ
    notifyListeners();
    try {
      // 1. Gọi repository đã được cập nhật
      final newUser = await _userRepository.createUser(userData);
      // 2. Thành công!
      ToastHelper.showSucess('Tạo tài khoản "${newUser.name}" thành công!');
      // 3. Tải lại trang đầu tiên để admin thấy user mới
      await fetchUsers(page: 1);
      return true;
    } catch (e) {
      _errorMessage =
          "Lỗi khi tạo người dùng: ${e.toString().replaceFirst('Exception: ', '')}";
      ToastHelper.showError(_errorMessage!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Gọi repository
      final updatedUser = await _userRepository.updateUser(userId, userData);
      ToastHelper.showSucess('Cập nhật "${updatedUser.name}" thành công!');
      await fetchUsers(page: _currentPage);

      return true;
    } catch (e) {
      _errorMessage =
          "Lỗi khi cập nhật: ${e.toString().replaceFirst('Exception: ', '')}";
      ToastHelper.showError(_errorMessage!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
