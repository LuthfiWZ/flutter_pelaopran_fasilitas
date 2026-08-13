import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "Tag kerja" status laporan — label teknis seperti stempel pada work order.
/// Bukan pill generik: sudut kecil (6), label MONO uppercase, titik warna.
/// Warna selalu membawa makna status, bukan dekorasi.
class StatusTag extends StatelessWidget {
  final String status;
  final String? label;

  const StatusTag({super.key, required this.status, this.label});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final text = label ?? AppColors.statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.tag),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
