import 'package:flutter/material.dart';
import 'package:mobile/data/models/admin_redemption_model.dart';
import 'package:mobile/domain/repositories/admin/admin_redemption_repository.dart';

class UserRedemptionViewModel extends ChangeNotifier {
  final AdminRedemptionRepository _repository;

  UserRedemptionViewModel(this._repository);

  List<AdminRedemptionModel> _redemptions = [];
  bool _isLoading = false;

  List<AdminRedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;

  Future<void> fetchUserRedemptions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _redemptions = await _repository.getUserRedemptions(userId);
    } catch (e) {
      debugPrint('Error fetching user redemptions: $e');
      _redemptions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmRedemption(String redemptionId, String userId) async {
    try {
      await _repository.confirmRedemption(redemptionId);
      // Reload redemptions after confirmation
      await fetchUserRedemptions(userId);
    } catch (e) {
      debugPrint('Error confirming redemption: $e');
    }
  }
}
