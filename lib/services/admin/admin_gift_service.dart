import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/domain/repositories/admin_gift_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminGiftService extends ChangeNotifier {
  final AdminGiftRepository _repository;

  AdminGiftService(this._repository);

  List<GiftModel> _gifts = [];
  bool _isLoading = false;
  bool _showDeleted = false; // Lọc thùng rác

  List<GiftModel> get gifts => _gifts;
  bool get isLoading => _isLoading;
  bool get showDeleted => _showDeleted;

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

  Future<bool> deleteGift(String id) async {
    try {
      await _repository.deleteGift(id);
      ToastHelper.showSuccess('Đã ẩn quà tặng');
      fetchGifts();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> restoreGift(String id) async {
    try {
      await _repository.restoreGift(id);
      ToastHelper.showSuccess('Khôi phục thành công');

      // Load lại danh sách để thấy món quà biến mất khỏi thùng rác (hoặc hiện lại ở list chính)
      fetchGifts();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
