import 'package:flutter/material.dart';

/// Batang horizontal untuk jumlah laporan per kategori.
class CategoryBars extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CategoryBars({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxTotal = data.isEmpty
        ? 1
        : data
            .map((e) => (e['total'] as num).toInt())
            .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final item in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    item['category']?.toString() ?? '-',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final total = (item['total'] as num).toInt();
                      final fraction = maxTotal == 0
                          ? 0.0
                          : (total / maxTotal).clamp(0.0, 1.0);
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 18,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          Container(
                            height: 18,
                            width: constraints.maxWidth * fraction,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item['total']}',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Grafik batang vertikal jumlah laporan per bulan (6 bulan terakhir).
class MonthBars extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const MonthBars({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = data.isEmpty
        ? 1
        : data
            .map((e) => (e['total'] as num).toInt())
            .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final item in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${item['total']}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height:
                          maxValue == 0
                              ? 2
                              : 90 * ((item['total'] as num).toInt() / maxValue),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label']?.toString().split(' ').first ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
