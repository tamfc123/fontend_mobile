import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/domain/repositories/student/student_profile_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class StudentProfileViewModel extends ChangeNotifier {
  final StudentProfileRepository _repository;

  StudentProfileViewModel(this._repository);

  UserModel? _profile;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
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
      final updatedProfile = await _repository.updateProfile(
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
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final avatarUrl = await _repository.updateAvatar(file);
      if (_profile != null && avatarUrl != null) {
        _profile = _profile!.copyWith(avatarUrl: avatarUrl);
      }
      ToastHelper.showSuccess('Cập nhật ảnh đại diện thành công');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.showError(_error!);
    } finally {
      _isUploading = false;
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
      await _repository.changePassword(
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
