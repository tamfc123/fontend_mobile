import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/constants/api_config.dart';
import 'package:mobile/utils/token_helper.dart';

class ApiClient {
  final Dio _dio;
  Dio get dio => _dio;
  ApiClient() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(
        seconds: 30,
      ), // Thời gian chờ kết nối server
      receiveTimeout: const Duration(
        seconds: 120,
      ), // Thời gian chờ AI xử lý (QUAN TRỌNG)
      sendTimeout: const Duration(seconds: 30), // Thời gian gửi file lên
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("Lỗi 401: Token hết hạn hoặc không hợp lệ.");
            // Xử lý khi token hết hạn hoặc không hợp lệ
            // Ví dụ: chuyển hướng người dùng đến trang đăng nhập
          }
          return handler.next(e);
        },
      ),
    );
  }
}
