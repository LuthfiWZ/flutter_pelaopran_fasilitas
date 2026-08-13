import 'package:dio/dio.dart';

import '../config/api_config.dart';

/// Wrapper tunggal (singleton) untuk konfigurasi Dio + interceptor token.
///
/// Interceptor `onRequest` menyisipkan header `Authorization: Bearer <token>`
/// secara otomatis untuk setiap request, jadi service lain tidak perlu
/// mengulang header. Token diatur lewat [setToken] saat login/restore.
class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  /// Mengekstrak pesan error dari response Laravel (validation / exception).
  static String errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend berjalan.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
