import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/data/models/room_model.dart';

class RoomRepository {
  final ApiClient _apiClient;
  RoomRepository(this._apiClient);

  // Lấy tất cả phòng học
  Future<List<RoomModel>> getRooms() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.adminRooms);
      return (response.data as List)
          .map((json) => RoomModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Không thể tải danh sách phòng',
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
          // ⚠️ Chú ý: 'capactity' là lỗi chính tả trong code cũ,
          // tôi sửa thành 'capacity' (dung lượng)
          // Hãy đảm bảo backend của bạn cũng dùng 'capacity'
          'capacity': room.capacity,
          'status': room.status,
        },
      );
      // Dio ném lỗi nếu status != 201
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Thêm phòng thất bại";
      throw Exception(errorMessage);
    }
  }

  // Cập nhật phòng học
  Future<void> updateRoom(int id, RoomModel room) async {
    try {
      await _apiClient.dio.put(
        ApiConfig.adminRoomById(id),
        data: {
          'name': room.name,
          'capacity': room.capacity, // ⚠️ Sửa 'capactity' thành 'capacity'
          'status': room.status,
        },
      );
      // Dio ném lỗi nếu status != 200
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? "Cập nhật phòng thất bại";
      throw Exception(errorMessage);
    }
  }

  // Xóa phòng học
  Future<void> deleteRoom(int id) async {
    try {
      await _apiClient.dio.delete(ApiConfig.adminRoomById(id));
      // Dio ném lỗi nếu status != 200/204
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? "Xóa phòng thất bại";
      throw Exception(errorMessage);
    }
  }
}
