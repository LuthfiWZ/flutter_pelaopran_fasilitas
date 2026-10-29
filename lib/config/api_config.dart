import 'package:flutter/foundation.dart';

/// Konfigurasi alamat backend.
///
/// Cara kerja:
/// - Bisa dioverride saat run/build lewat `--dart-define=API_URL=...`
///   contoh: `flutter run --dart-define=API_URL=http://192.168.1.10:8000/api/v1`
/// - Tanpa override, web memakai localhost dan emulator Android memakai
///   10.0.2.2 (alias localhost dari sisi emulator).
class ApiConfig {
  static const String _defineUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_defineUrl.isNotEmpty) return _defineUrl;
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// Base URL folder `storage` Laravel, untuk menampilkan foto laporan.
  static String get storageBaseUrl {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}/storage';
  }

  /// Membangun URL lengkap foto dari path relatif yang dikirim backend.
  static String photoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final clean = path.replaceFirst(RegExp(r'^/+'), '');
    return '$storageBaseUrl/$clean';
  }
}
