import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/domain/repositories/admin/admin_gift_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageGiftViewModel extends ChangeNotifier {
  final AdminGiftRepository _repository;

  ManageGiftViewModel(this._repository);

  List<GiftModel> _gifts = [];
  bool _isLoading = false;
  bool _showDeleted = false;

  List<GiftModel> get gifts => _gifts;
  bool get isLoading => _isLoading;
  bool get showDeleted => _showDeleted;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  final int _pageSize = 5;
  List<GiftModel> get filteredGifts => _gifts;

  Future<void> fetchGifts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getGifts(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
        returnDeleted: _showDeleted,
      );
      _gifts = result.items;
      _totalCount = result.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      _gifts = [];
      _totalCount = 0;
      _totalPages = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applySearch(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    _currentPage = 1;
    fetchGifts();
  }

  void toggleShowDeleted() {
    _showDeleted = !_showDeleted;
    _currentPage = 1;
    fetchGifts();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await fetchGifts();
  }

  Future<bool> createGift(GiftModel gift) async {
    try {
      await _repository.createGift(gift);
      ToastHelper.showSuccess('Thêm quà tặng thành công');
      fetchGifts();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateGift(String id, GiftModel gift) async {
    try {
      await _repository.updateGift(id, gift);
      ToastHelper.showSuccess('Cập nhật thành công');
      fetchGifts();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      await _repository.deleteGift(id);
      ToastHelper.showSuccess('Đã ẩn quà tặng');
      fetchGifts();
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> restoreGift(String id) async {
    try {
      await _repository.restoreGift(id);
      ToastHelper.showSuccess('Khôi phục thành công');
      fetchGifts();
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
