  import '../config/api_config.dart';
import 'category.dart';
import 'status_log.dart';

class Report {
  final int id;
  final int userId;
  final String? reporterName;
  final String? reporterEmail;
  final Category? category;
  final String title;
  final String description;
  final String location;
  final String? building;
  final String? room;
  final String? photo;
  final String? photoUrlFromApi;
  final String status;
  final String statusLabel;
  final String? note;
  final List<StatusLog> timeline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    required this.id,
    required this.userId,
    this.reporterName,
    this.reporterEmail,
    this.category,
    required this.title,
    required this.description,
    required this.location,
    this.building,
    this.room,
    this.photo,
    this.photoUrlFromApi,
    required this.status,
    required this.statusLabel,
    this.note,
    this.timeline = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// URL lengkap foto untuk ditampilkan.
  String get photoUrl {
    if (photoUrlFromApi != null && photoUrlFromApi!.isNotEmpty) {
      return photoUrlFromApi!;
    }
    return ApiConfig.photoUrl(photo);
  }

  bool get isDone => status == 'selesai';

  String get fullLocation {
    final parts = [location, building, room].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(' · ');
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    final rawTimeline = json['timeline'] as List<dynamic>? ?? const [];

    return Report(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      reporterName: reporter?['name'] as String?,
      reporterEmail: reporter?['email'] as String?,
      category: category == null ? null : Category.fromJson(category),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      building: json['building'] as String?,
      room: json['room'] as String?,
      photo: json['photo'] as String?,
      photoUrlFromApi: json['photo_url'] as String?,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String? ?? json['status'] as String,
      note: json['note'] as String?,
      timeline: rawTimeline
          .whereType<Map<String, dynamic>>()
          .map(StatusLog.fromJson)
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}
