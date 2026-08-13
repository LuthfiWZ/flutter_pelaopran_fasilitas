import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/formatters.dart';
import 'report_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getNotifications();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat notifikasi';
        _loading = false;
      });
    }
  }

  Future<void> _open(NotificationItem item) async {
    if (!item.read) {
      await _service.markAsRead(item.id);
      setState(() {
        _items = _items.map((i) {
          if (i.id == item.id) {
            return NotificationItem(
              id: i.id,
              data: i.data,
              read: true,
              createdAt: i.createdAt,
            );
          }
          return i;
        }).toList();
      });
    }

    final reportId = item.data['report_id'];
    if (reportId is int && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: reportId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Tandai semua dibaca',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await _service.markAllAsRead();
              _load();
            },
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text('Tidak ada notifikasi'),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item.read
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.campaign_outlined,
              color: item.read
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
          title: Text(
            item.message,
            style: TextStyle(
              fontWeight: item.read ? FontWeight.normal : FontWeight.w700,
            ),
          ),
          subtitle: Text(Formatters.dateTime(item.createdAt)),
          onTap: () => _open(item),
        );
      },
    );
  }
}
