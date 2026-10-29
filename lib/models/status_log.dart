import '../config/api_config.dart';

class StatusLog {
  final int id;
  final String status;
  final String statusLabel;
  final String? note;
  final String? photo;
  final String? userName;
  final DateTime? createdAt;

  StatusLog({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.note,
    this.photo,
    this.userName,
    this.createdAt,
  });

  String get photoUrl {
    final apiUrl = photo != null && photo!.isNotEmpty ? (photo!.startsWith('http') ? photo! : null) : null;
    if (apiUrl != null) return apiUrl;
    return ApiConfig.photoUrl(photo);
  }

  factory StatusLog.fromJson(Map<String, dynamic> json) {
    String? photoVal = json['photo'] as String?;
    final photoUrlJson = json['photo_url'] as String?;
    if ((photoVal == null || photoVal.isEmpty) && photoUrlJson != null && photoUrlJson.isNotEmpty) {
      // If full URL, still keep it; ApiConfig.photoUrl handles absolute URLs fine? but our ApiConfig expects relative - better to pass as-is by checking
      // easier: store full URL in photo if absolute
      if (photoUrlJson.startsWith('http')) {
        photoVal = photoUrlJson;
      }
    }
    return StatusLog(
      id: json['id'] as int,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String? ?? json['status'] as String,
      note: json['note'] as String?,
      photo: photoVal ?? photoUrlJson,
      userName: json['user_name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
