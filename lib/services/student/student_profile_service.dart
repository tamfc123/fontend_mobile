import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/student_profile_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentProfileService extends ChangeNotifier {
  final StudentProfileRepository _profileRepository;

  StudentProfileService(this._profileRepository);

  UserModel? _profile;
  bool _isLoading = false;
  String? _error;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    DateTime? birthday,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = await _profileRepository.updateProfile(
        name: name,
        phone: phone,
        birthday: birthday,
      );

      _profile = updatedProfile;
      ToastHelper.showSuccess('Cập nhật thành công');
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final avatarUrl = await _profileRepository.updateAvatar(file);
      if (_profile != null && avatarUrl != null) {
        _profile = _profile!.copyWith(avatarUrl: avatarUrl);
      }
      ToastHelper.showSuccess('Cập nhật ảnh đại diện thành công');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      ToastHelper.showSuccess('Đổi mật khẩu thành công');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateLocalStreak(int newStreak) {
    if (_profile == null) return;

    if (_profile!.currentStreak != newStreak) {
      _profile = _profile!.copyWith(currentStreak: newStreak);
      notifyListeners();
    }
  }

  void updateLocalExp(int newExp) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(experiencePoints: newExp);

    int currentLevel = _profile!.level;
    int expNeeded = _getExpNeededForLevel(currentLevel);

    while (expNeeded > 0 && _profile!.experiencePoints >= expNeeded) {
      _profile = _profile!.copyWith(
        level: _profile!.level + 1,
        experiencePoints: _profile!.experiencePoints - expNeeded,
      );
      expNeeded = _getExpNeededForLevel(_profile!.level);
    }

    notifyListeners();
  }

  // Bạn có thể reuse logic từ UI (hoặc move _getExpNeededForLevel vào ProfileService)
  int _getExpNeededForLevel(int level) {
    switch (level) {
      case 1:
        return 100;
      case 2:
        return 250;
      case 3:
        return 500;
      case 4:
        return 1000;
      case 5:
        return 2000;
      case 6:
        return 0; // Max
      default:
        return 100;
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
