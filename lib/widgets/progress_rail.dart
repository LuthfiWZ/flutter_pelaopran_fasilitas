import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ============================================================================
/// ELEMEN SIGNATURE — "Progress Rail"
/// ----------------------------------------------------------------------------
/// Trek perbaikan 4 stasiun (LAPOR → CEK → PERBAIKAN → SELESAI) ala papan
/// papan status di bengkel. Status bisa dibaca dalam satu pandangan:
///   - titik terisi warna = tahap sudah lewat (warna sesuai makna status)
///   - titik EMBER          = tahap yang sedang berjalan (satu aksen berani)
///   - titik kosong         = tahap yang belum dicapai
/// Bukan stepper Material default, dan bukan dekorasi: setiap warna = info.
/// ============================================================================
class ProgressRail extends StatelessWidget {
  final String currentStatus;
  final double? labelWidth;

  const ProgressRail({
    super.key,
    required this.currentStatus,
    this.labelWidth,
  });

  static const _steps = ['dilaporkan', 'diverifikasi', 'diproses', 'selesai'];
  static const _labels = ['Lapor', 'Cek', 'Perbaikan', 'Selesai'];

  int get _reachedIndex {
    final index = _steps.indexOf(currentStatus);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final reached = _reachedIndex;

    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(child: _connector(filled: reached >= i)),
                    _node(step: _steps[i], index: i, reached: reached),
                    if (i < _steps.length - 1)
                      Expanded(
                        child: _connector(filled: reached > i, next: _steps[i + 1]),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _label(step: _steps[i], index: i, reached: reached),
              ],
            ),
          ),
      ],
    );
  }

  Widget _node({required String step, required int index, required int reached}) {
    final color = AppColors.statusColor(step);

    if (index < reached) {
      // Tahap sudah selesai
      return _circle(
        size: 30,
        color: color,
        child: const Icon(Icons.check, size: 15, color: Colors.white),
      );
    }

    if (index == reached) {
      // Tahap aktif — satu-satunya tempat Ember "menyala"
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ember.withValues(alpha: 0.12),
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ember,
            boxShadow: [
              BoxShadow(
                color: Color(0x33E2531D),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            AppColors.statusIcon(step),
            size: 15,
            color: Colors.white,
          ),
        ),
      );
    }

    // Belum dicapai
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.stone.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          fontFamily: AppFonts.mono,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.stone,
        ),
      ),
    );
  }

  Widget _connector({required bool filled, String? next}) {
    final color = filled && next != null
        ? AppColors.statusColor(next)
        : AppColors.stone.withValues(alpha: 0.35);
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: color,
    );
  }

  Widget _label({required String step, required int index, required int reached}) {
    final color = index <= reached
        ? AppColors.statusColor(step)
        : AppColors.stone.withValues(alpha: 0.7);
    return Text(
      _labels[index].toUpperCase(),
      style: TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: 9.5,
        fontWeight: index == reached ? FontWeight.w700 : FontWeight.w500,
        letterSpacing: 1,
        color: index == reached ? AppColors.ember : color,
      ),
    );
  }

  Widget _circle({required double size, required Color color, required Widget child}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: child,
    );
  }
}
