import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/data/models/student_redemption_model.dart';
import 'package:mobile/domain/repositories/student_gift_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentGiftService extends ChangeNotifier {
  final StudentGiftRepository _repository;

  StudentGiftService(this._repository);

  List<GiftModel> _gifts = [];
  List<StudentRedemptionModel> _redemptions = [];
  bool _isLoading = false;

  List<GiftModel> get gifts => _gifts;
  List<StudentRedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;

  // Lấy dữ liệu cho màn hình Cửa hàng
  Future<void> fetchStoreData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _gifts = await _repository.getAvailableGifts();
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy dữ liệu cho màn hình Lịch sử
  Future<void> fetchMyRedemptions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _redemptions = await _repository.getMyRedemptions();
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hành động Đổi quà
  Future<bool> redeemGift(String giftId) async {
    try {
      final newBalance = await _repository.redeemGift(giftId);

      ToastHelper.showSuccess(
        'Đổi quà thành công! Hãy đến quầy lễ tân nhận quà.',
      );

      // Refresh lại cả 2 list để update số lượng tồn kho & lịch sử
      fetchStoreData();
      fetchMyRedemptions();

      return true; // Trả về true để UI biết mà trừ coin animation (nếu có)
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
