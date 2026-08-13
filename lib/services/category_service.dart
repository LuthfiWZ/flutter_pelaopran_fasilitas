import 'package:dio/dio.dart';

import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    final raw = response.data['data'] as List<dynamic>;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  Future<Category> createCategory({
    required String name,
    String? description,
  }) async {
    final response = await _dio.post('/categories', data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return Category.fromJson(response.data['data']);
  }

  Future<Category> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
    final response = await _dio.put('/categories/$id', data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return Category.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('/categories/$id');
  }
}
