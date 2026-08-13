import 'package:dio/dio.dart';

import 'api_client.dart';

class NotificationItem {
  final String id;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.data,
    required this.read,
    this.createdAt,
  });

  String get message => data['message']?.toString() ?? 'Notifikasi baru';

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
      read: json['read_at'] != null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class NotificationService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _dio.get('/notifications');
    final raw = response.data['data'] as List<dynamic>;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('/notifications/$id');
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/notifications');
  }
}
