import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/data/models/student_redemption_model.dart';
import 'package:mobile/domain/repositories/student/student_gift_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentGiftViewModel extends ChangeNotifier {
  final StudentGiftRepository _repository;

  StudentGiftViewModel(this._repository);

  List<GiftModel> _gifts = [];
  List<StudentRedemptionModel> _redemptions = [];
  bool _isLoading = false;

  List<GiftModel> get gifts => _gifts;
  List<StudentRedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;

  Future<void> loadStoreData() async {
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

  Future<void> loadMyRedemptions() async {
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

  Future<bool> redeemGift(String giftId) async {
    try {
      await _repository.redeemGift(giftId);

      ToastHelper.showSuccess(
        'Đổi quà thành công! Hãy đến quầy lễ tân nhận quà.',
      );

      // Refresh both lists
      loadStoreData();
      loadMyRedemptions();

      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
