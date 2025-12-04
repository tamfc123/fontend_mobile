import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/admin/admin_user_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

enum UserRole { all, admin, teacher, student }

enum UserStatus { all, active, blocked }

enum UserSortOption { nameAsc, nameDesc, emailAsc, emailDesc }

class ManageAccountViewModel extends ChangeNotifier {
  final AdminUserRepository _userRepository;

  ManageAccountViewModel(this._userRepository);

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 5;
  int _totalPages = 1;
  int _totalItems = 0;

  String _searchQuery = '';
  UserRole _roleFilter = UserRole.all;
  UserStatus _statusFilter = UserStatus.all;
  UserSortOption _sortOption = UserSortOption.nameAsc;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;

  String get searchQuery => _searchQuery;
  UserRole get roleFilter => _roleFilter;
  UserStatus get statusFilter => _statusFilter;
  UserSortOption get sortOption => _sortOption;

  Timer? _debounce;

  // Initialize data
  void init() {
    fetchUsers(page: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchUsers({int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      fetchUsers(page: 1);
    });
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

  Future<void> toggleUserStatus(String id) async {
    // Optimistic update or wait for server?
    // Let's wait for server as in original code
    try {
      final success = await _userRepository.toggleUserStatus(id);
      if (success) {
        ToastHelper.showSuccess("Cập nhật trạng thái thành công!");
        await fetchUsers(page: _currentPage);
      }
    } catch (e) {
      ToastHelper.showError(
        "Lỗi khi cập nhật trạng thái: ${e.toString().replaceFirst('Exception: ', '')}",
      );
    }
  }

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
}
