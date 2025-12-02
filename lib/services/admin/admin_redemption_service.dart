import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_redemption_model.dart';
import 'package:mobile/domain/repositories/admin_redemption_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminRedemptionService extends ChangeNotifier {
  final AdminRedemptionRepository _repository;

  AdminRedemptionService(this._repository);

  List<AdminRedemptionModel> _redemptions = [];
  bool _isLoading = false;

  List<AdminRedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;

  Future<void> fetchUserRedemptions(String userId) async {
    _isLoading = true;
    _redemptions = []; // Clear data cũ
    notifyListeners();

    try {
      _redemptions = await _repository.getUserRedemptions(userId);
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmRedemption(String redemptionId, String userId) async {
    try {
      await _repository.confirmRedemption(redemptionId);
      ToastHelper.showSuccess('Đã xác nhận trao quà!');
      // Reload lại list để cập nhật trạng thái
      await fetchUserRedemptions(userId);
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
