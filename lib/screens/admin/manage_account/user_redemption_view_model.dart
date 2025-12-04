import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_redemption_model.dart';
import 'package:mobile/domain/repositories/admin/admin_redemption_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class UserRedemptionViewModel extends ChangeNotifier {
  final AdminRedemptionRepository _repository;

  UserRedemptionViewModel(this._repository);

  List<AdminRedemptionModel> _redemptions = [];
  bool _isLoading = false;
  String? _error;

  List<AdminRedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserRedemptions(String userId) async {
    _isLoading = true;
    _error = null;
    _redemptions = [];
    notifyListeners();

    try {
      _redemptions = await _repository.getUserRedemptions(userId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmRedemption(String redemptionId, String userId) async {
    try {
      await _repository.confirmRedemption(redemptionId);
      ToastHelper.showSuccess('Đã xác nhận trao quà!');
      // Reload list to update status
      await fetchUserRedemptions(userId);
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
