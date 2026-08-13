import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Label bagian bergaya "inspection report": teks mono uppercase dengan
/// garis aksen ember pendek di depan. Memberi ritme pada halaman panjang.
class SectionLabel extends StatelessWidget {
  final String text;
  final bool ember;

  const SectionLabel({super.key, required this.text, this.ember = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 2,
          color: ember ? AppColors.ember : AppColors.stone,
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.stone,
          ),
        ),
      ],
    );
  }
}
