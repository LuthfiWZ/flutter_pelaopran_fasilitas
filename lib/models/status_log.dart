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

  String get photoUrl => ApiConfig.photoUrl(photo);

  factory StatusLog.fromJson(Map<String, dynamic> json) {
    return StatusLog(
      id: json['id'] as int,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String? ?? json['status'] as String,
      note: json['note'] as String?,
      photo: json['photo'] as String?,
      userName: json['user_name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
