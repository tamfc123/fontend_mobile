import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/room_repository.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/toast_helper.dart';

class RoomService extends ChangeNotifier {
  final RoomRepository _roomRepository;
  RoomService(this._roomRepository);

  List<RoomModel> _allRooms = []; // dữ liệu gốc
  List<RoomModel> _rooms = []; // dữ liệu đã lọc
  bool _isLoading = false;
  String _searchQuery = "";

  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;

  // Fetch all rooms
  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 5. GỌI REPOSITORY
      _allRooms = await _roomRepository.getRooms();
      _applyFilters();
    } catch (e) {
      debugPrint("Error fetching rooms: $e");
      _allRooms = [];
      _rooms = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new room
  Future<bool> addRoom(RoomModel room) async {
    try {
      // 6. GỌI REPOSITORY
      await _roomRepository.createRoom(room);
      await fetchRooms(); // Tải lại danh sách sau khi thêm
      ToastHelper.showSucess('Thêm phòng học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Update room
  Future<bool> updateRoom(int id, RoomModel room) async {
    try {
      // 7. GỌI REPOSITORY
      await _roomRepository.updateRoom(id, room);
      await fetchRooms(); // Tải lại danh sách sau khi cập nhật
      ToastHelper.showSucess('Cập nhật phòng học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Delete room
  Future<bool> deleteRoom(int id) async {
    try {
      // 8. GỌI REPOSITORY
      await _roomRepository.deleteRoom(id);

      // Cập nhật UI (tối ưu, không cần fetch lại)
      _allRooms.removeWhere((r) => r.id == id);
      _applyFilters();
      notifyListeners();

      ToastHelper.showSucess('Xóa phòng học thành công');
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // --- (Các hàm filter không đổi) ---
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _rooms =
        _allRooms.where((room) {
          final matchSearch = room.name.toLowerCase().contains(_searchQuery);
          return matchSearch;
        }).toList();
  }

  List<RoomModel> filterByStatus(String status) {
    return _allRooms.where((r) => r.status == status).toList();
  }
}
