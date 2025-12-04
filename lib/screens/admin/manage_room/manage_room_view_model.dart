import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/admin/admin_room_repository.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageRoomViewModel extends ChangeNotifier {
  final AdminRoomRepository _roomRepository;

  ManageRoomViewModel(this._roomRepository);

  List<RoomModel> _rooms = [];
  List<RoomModel> get rooms => _rooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  final int _pageSize = 5;

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _roomRepository.getRooms(
        pageNumber: _currentPage,
        search: _searchQuery,
      );

      _rooms = result.items;
      _totalCount = result.totalCount;
      _totalPages = (_totalCount / _pageSize).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      ToastHelper.showError('Lỗi tải danh sách phòng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySearch(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    await fetchRooms();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await fetchRooms();
  }

  Future<bool> createRoom(RoomModel room) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _roomRepository.createRoom(room);
      ToastHelper.showSuccess('Thêm phòng học thành công');
      await fetchRooms();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRoom(String id, RoomModel room) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _roomRepository.updateRoom(id, room);
      ToastHelper.showSuccess('Cập nhật phòng học thành công');
      await fetchRooms();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoom(String id) async {
    try {
      await _roomRepository.deleteRoom(id);
      ToastHelper.showSuccess('Xóa phòng học thành công');
      // Nếu xóa item cuối cùng của trang, quay lại trang trước
      if (_rooms.length == 1 && _currentPage > 1) {
        _currentPage--;
      }
      await fetchRooms();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
