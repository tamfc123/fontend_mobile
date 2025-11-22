import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/paged_result_model.dart';
import 'package:mobile/data/models/room_model.dart';

class AdminRoomRepository {
  final ApiClient _apiClient;
  AdminRoomRepository(this._apiClient);

  // Lấy danh sách phòng học CÓ PHÂN TRANG
  Future<PagedResultModel<RoomModel>> getRooms({
    String? search,
    int pageNumber = 1,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminRooms,
        queryParameters: {'search': search, 'pageNumber': pageNumber},
      );

      return PagedResultModel.fromJson(
        response.data,
        (json) => RoomModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách phòng',
      );
    }
  }

  Future<List<RoomModel>> getAllActiveRooms() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.adminGetAllActiveRooms,
      );
      return (response.data as List)
          .map((json) => RoomModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách phòng (active)',
      );
    }
  }

  // Tạo phòng học
  Future<void> createRoom(RoomModel room) async {
    try {
      await _apiClient.dio.post(
        ApiConfig.adminRooms,
        data: {
          'name': room.name,
          'capactity': room.capactity,
          'status': room.status,
        },
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Thêm phòng thất bại";
      throw Exception(errorMessage);
    }
  }

  Future<void> updateRoom(String id, RoomModel room) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminRoomById(id),
        data: {
          'name': room.name,
          'capactity': room.capactity,
          'status': room.status,
        },
      );
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Cập nhật phòng thất bại";
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminRoomById(id));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? "Xóa phòng thất bại";
      throw Exception(errorMessage);
    }
  }
}
