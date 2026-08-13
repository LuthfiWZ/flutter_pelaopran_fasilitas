import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/status_log.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'photo_viewer.dart';
import 'status_tag.dart';

/// Log vertikal riwayat perbaikan bergaya "stempel work order":
/// rel putus-putus, titik node sesuai warna status, tanggal memakai font mono.
class TimelineView extends StatelessWidget {
  final List<StatusLog> logs;

  const TimelineView({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'BELUM ADA RIWAYAT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 11,
            letterSpacing: 1.4,
            color: AppColors.stone,
          ),
        ),
      );
    }

    final sorted = [...logs]..sort((a, b) {
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });

    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          _LogEntry(
            log: sorted[i],
            isFirst: i == 0,
            isLast: i == sorted.length - 1,
          ),
      ],
    );
  }
}

class _LogEntry extends StatelessWidget {
  final StatusLog log;
  final bool isFirst;
  final bool isLast;

  const _LogEntry({
    required this.log,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(log.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rel + node
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    AppColors.statusIcon(log.status),
                    size: 11,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _DashedRailPainter(color: color.withValues(alpha: 0.4)),
                      child: const SizedBox(width: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Isi
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 2,
                bottom: isLast ? 0 : AppSpace.lg,
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.stone.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: StatusTag(status: log.status)),
                        Text(
                          Formatters.dateTime(log.createdAt),
                          style: const TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 9.5,
                            letterSpacing: 0.4,
                            color: AppColors.stone,
                          ),
                        ),
                      ],
                    ),
                    if (log.userName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'oleh ${log.userName}',
                        style: const TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 10,
                          color: AppColors.stone,
                        ),
                      ),
                    ],
                    if (log.note != null && log.note!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        log.note!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (log.photo != null && log.photo!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _ProgressPhoto(path: log.photo!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPhoto extends StatelessWidget {
  final String path;

  const _ProgressPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.photoUrl(path);
    return GestureDetector(
      onTap: () => PhotoViewer.show(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: CachedNetworkImage(
          imageUrl: url,
          height: 120,
          width: 180,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => Container(
            height: 120,
            width: 180,
            color: AppColors.fog,
            child: const Icon(Icons.broken_image_outlined, color: AppColors.stone),
          ),
        ),
      ),
    );
  }
}

class _DashedRailPainter extends CustomPainter {
  final Color color;

  _DashedRailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 4.0;
    final x = size.width / 2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRailPainter oldDelegate) =>
      oldDelegate.color != color;
}
