import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/report.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'status_tag.dart';

/// Kartu laporan dengan strip warna status di tepi kiri agar daftar bisa
/// di-scan cepat lewat warna, plus nomor tiket mono (LP-0001).
class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.statusColor(report.status);

    return AppCard(
      onTap: onTap,
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoThumb(url: report.photoUrl, accent: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      ticketNumber(report.id),
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: AppColors.stone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.category?.name ?? '-',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusTag(status: report.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.stone,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 13,
                      color: AppColors.stone,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.fullLocation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.stone,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 13, color: AppColors.stone),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.dateTime(report.createdAt),
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 9.5,
                        color: AppColors.stone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String url;
  final Color accent;

  const _PhotoThumb({required this.url, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = 76.0;

    Widget placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.fog,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.stone,
      ),
    );

    if (url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
