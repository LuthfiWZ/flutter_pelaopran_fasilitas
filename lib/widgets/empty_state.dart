import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum EmptyStateKind { empty, error }

/// Empty/error state dengan ilustrasi custom (bukan hanya teks datar):
/// clipboard "work order" + kunci pas, digambar via CustomPainter.
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final EmptyStateKind kind;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.kind = EmptyStateKind.empty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              height: 130,
              child: CustomPaint(
                painter: icon == null
                    ? _RepairIllustrationPainter(error: kind == EmptyStateKind.error)
                    : null,
                child: icon == null
                    ? null
                    : Icon(
                        icon,
                        size: 56,
                        color: kind == EmptyStateKind.error
                            ? AppColors.rust
                            : AppColors.ember,
                      ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.stone,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpace.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ilustrasi custom: clipboard work order + kunci pas.
class _RepairIllustrationPainter extends CustomPainter {
  final bool error;

  _RepairIllustrationPainter({required this.error});

  @override
  void paint(Canvas canvas, Size size) {
    final accent = error ? AppColors.rust : AppColors.ember;

    // === Clipboard body ===
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 28, 100, 96),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()..color = AppColors.fog,
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = AppColors.stone.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Clip di atas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(52, 14, 36, 16),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.stone.withValues(alpha: 0.7),
    );

    // Garis "kertas"
    final linePaint = Paint()
      ..color = AppColors.stone.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final dy in [44.0, 56.0, 68.0]) {
      canvas.drawLine(Offset(32, dy), Offset(88, dy), linePaint);
    }

    // Tanda cek/status pada kertas
    if (!error) {
      canvas.drawLine(
        const Offset(36, 106),
        const Offset(50, 120),
        Paint()
          ..color = AppColors.moss
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        const Offset(50, 120),
        const Offset(78, 92),
        Paint()
          ..color = AppColors.moss
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawLine(
        const Offset(40, 98),
        const Offset(76, 112),
        Paint()
          ..color = AppColors.rust
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        const Offset(76, 98),
        const Offset(40, 112),
        Paint()
          ..color = AppColors.rust
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    // === Kunci pas (stylized) ===
    final wrenchPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(96, 48), const Offset(120, 72), wrenchPaint);
    // Kepala kunci: cincin dengan rahang terbuka
    canvas.drawCircle(const Offset(124, 78), 15, wrenchPaint);
    canvas.drawCircle(
      const Offset(116, 86),
      8,
      Paint()..color = AppColors.bone,
    );

    // Titik aksen kecil (ritme)
    canvas.drawCircle(
      const Offset(30, 116),
      3,
      Paint()..color = accent.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _RepairIllustrationPainter oldDelegate) =>
      oldDelegate.error != error;
}
