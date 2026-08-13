import 'package:dio/dio.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return (
      user: User.fromJson(response.data['user']),
      token: response.data['token'] as String,
    );
  }

  Future<({User user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return (
      user: User.fromJson(response.data['user']),
      token: response.data['token'] as String,
    );
  }

  /// Mengambil data user untuk token yang disimpan (restore sesi).
  Future<User> me() async {
    final response = await _dio.get('/user');
    return User.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    await _dio.post('/logout');
  }
}
