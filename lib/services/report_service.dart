import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../models/report.dart';
import 'api_client.dart';

class ReportService {
  final Dio _dio = ApiClient.instance.dio;

  /// Menyisipkan file foto ke FormData dengan aman di semua platform
  /// (mobile & web) via bytes, bukan path filesystem.
  static Future<MapEntry<String, MultipartFile>> _photoPart(XFile photo) async {
    final bytes = await photo.readAsBytes();
    return MapEntry(
      'photo',
      MultipartFile.fromBytes(
        bytes,
        filename: photo.name,
      ),
    );
  }

  /// Daftar laporan. Untuk admin menerima parameter filter opsional.
  Future<List<Report>> getReports({
    String? status,
    int? categoryId,
    String? search,
    String? building,
  }) async {
    final query = <String, dynamic>{
      'status': status,
      'category_id': categoryId,
      'search': search,
      'building': building,
    }..removeWhere((_, value) =>
        value == null || (value is String && value.isEmpty));

    final response = await _dio.get('/reports', queryParameters: query);
    final raw = response.data['data'] as List<dynamic>;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Report.fromJson)
        .toList();
  }

  Future<Report> getReport(int id) async {
    final response = await _dio.get('/reports/$id');
    return Report.fromJson(response.data['data']);
  }

  /// Buat laporan baru (multipart, termasuk foto opsional).
  Future<Report> createReport({
    required int categoryId,
    required String title,
    required String description,
    required String location,
    String? building,
    String? room,
    XFile? photo,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,
      'title': title,
      'description': description,
      'location': location,
      if (building != null && building.isNotEmpty) 'building': building,
      if (room != null && room.isNotEmpty) 'room': room,
    });
    if (photo != null) {
      formData.files.add(await _photoPart(photo));
    }

    final response = await _dio.post('/reports', data: formData);
    return Report.fromJson(response.data['data']);
  }

  /// Update status oleh admin (multipart, foto progres opsional).
  Future<Report> updateStatus({
    required int reportId,
    required String status,
    String? note,
    XFile? photo,
  }) async {
    final formData = FormData.fromMap({
      'status': status,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    if (photo != null) {
      formData.files.add(await _photoPart(photo));
    }

    final response =
        await _dio.put('/reports/$reportId/status', data: formData);
    return Report.fromJson(response.data['data']);
  }

  Future<void> deleteReport(int id) async {
    await _dio.delete('/reports/$id');
  }

  /// Statistik untuk dashboard admin.
  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get('/admin/stats');
    return Map<String, dynamic>.from(response.data);
  }
}
