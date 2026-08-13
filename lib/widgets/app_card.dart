import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu khas aplikasi: permukaan putih, sudut besar (20), border tipis,
/// TANPA shadow tebal. Opsional strip warna di kiri (misal warna status)
/// sehingga daftar laporan bisa di-scan cepat lewat tepi kartu.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final Color color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.accent,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.stone.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (accent != null) Container(width: 4, color: accent),
                Expanded(
                  child: Padding(padding: padding, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
