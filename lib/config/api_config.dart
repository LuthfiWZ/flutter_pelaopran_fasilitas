import 'package:flutter/foundation.dart';

/// Konfigurasi alamat backend.
///
/// Cara kerja:
/// - Bisa dioverride saat run/build lewat `--dart-define=API_URL=...`
///   contoh: `flutter run --dart-define=API_URL=http://192.168.1.10:8000/api/v1`
/// - Tanpa override, web memakai host halaman (port 8000) agar foto tidak
///   mengarah ke localhost saat dibuka dari IP LAN; emulator Android memakai
///   10.0.2.2.
class ApiConfig {
  static const String _defineUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_defineUrl.isNotEmpty) return _defineUrl;
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return 'http://$host:8000/api/v1';
      }
      return 'http://localhost:8000/api/v1';
    }
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// Origin backend (skema + host + port), tanpa path `/api/v1`.
  static String get backendOrigin => Uri.parse(baseUrl).origin;

  /// Base URL folder `storage` Laravel, untuk menampilkan foto laporan.
  static String get storageBaseUrl => '$backendOrigin/storage';

  /// Membangun URL lengkap foto dari path relatif atau URL absolut backend.
  ///
  /// URL dari Laravel (`APP_URL` localhost) diubah ke host API yang sedang
  /// dipakai, supaya foto tetap ke backend yang benar.
  static String photoUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    var relative = path.trim();
    final parsed = Uri.tryParse(relative);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      relative = parsed.path;
    }

    relative = relative.replaceFirst(RegExp(r'^/+'), '');
    if (relative.startsWith('storage/')) {
      return '$backendOrigin/$relative';
    }
    return '$storageBaseUrl/$relative';
  }
}
