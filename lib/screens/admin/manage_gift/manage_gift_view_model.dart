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

  List<GiftModel> get filteredGifts {
    if (_searchQuery.isEmpty) return _gifts;
    return _gifts
        .where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void applySearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowDeleted() {
    _showDeleted = !_showDeleted;
    fetchGifts();
  }

  Future<void> fetchGifts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _gifts = await _repository.getGifts(returnDeleted: _showDeleted);
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      _gifts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
