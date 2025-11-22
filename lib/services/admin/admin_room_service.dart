import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/domain/repositories/admin_room_repository.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/toast_helper.dart';

class AdminRoomService extends ChangeNotifier {
  final AdminRoomRepository _roomRepository;
  AdminRoomService(this._roomRepository);

  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RoomModel> _allActiveRooms = [];
  List<RoomModel> get allActiveRooms => _allActiveRooms;

  String? _searchQuery;
  int _currentPage = 1;
  int _totalCount = 0;
  int _totalPages = 0;

  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get searchQuery => _searchQuery;

  Future<void> fetchAllActiveRooms() async {
    try {
      _allActiveRooms = await _roomRepository.getAllActiveRooms();
      notifyListeners();
    } catch (e) {
      ToastHelper.showError(
        'Lỗi tải danh sách phòng: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  // Fetch all rooms
  Future<void> fetchRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final PagedResultModel<RoomModel> result = await _roomRepository.getRooms(
        search: _searchQuery,
        pageNumber: _currentPage,
      );

      _rooms = result.items;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _currentPage = result.pageNumber;
    } catch (e) {
      _rooms = [];
      _errorMessage =
          'Lỗi khi tải phòng học: ${e.toString().replaceFirst('Exception: ', '')}';
      ToastHelper.showError(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applySearch(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1; // Luôn reset về trang 1 khi search
    await fetchRooms();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || (page > _totalPages && _totalPages > 0))
      return; // Trang không hợp lệ
    _currentPage = page;
    await fetchRooms();
  }

  // Add new room
  Future<bool> addRoom(RoomModel room) async {
    try {
      // 6. GỌI REPOSITORY
      await _roomRepository.createRoom(room);
      ToastHelper.showSuccess('Thêm phòng học thành công');

      _currentPage = 1;
      _searchQuery = null;
      await fetchRooms();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Update room
  Future<bool> updateRoom(String id, RoomModel room) async {
    try {
      // 7. GỌI REPOSITORY
      await _roomRepository.updateRoom(id, room);
      ToastHelper.showSuccess('Cập nhật phòng học thành công');
      await fetchRooms(); // Tải lại danh sách sau khi cập nhật
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Delete room
  Future<bool> deleteRoom(String id) async {
    try {
      // 8. GỌI REPOSITORY
      await _roomRepository.deleteRoom(id);
      ToastHelper.showSuccess('Xóa phòng học thành công');
      await fetchRooms();
      return true;
    } catch (e) {
      ToastHelper.showError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
