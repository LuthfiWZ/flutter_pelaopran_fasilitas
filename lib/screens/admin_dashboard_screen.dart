import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import '../widgets/stats_charts.dart';
import 'category_management_screen.dart';
import 'notifications_screen.dart';
import 'report_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportProvider>();
      provider.loadReports();
      provider.loadCategories();
      provider.loadStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            tooltip: 'Kategori',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CategoryManagementScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterSection(
            categories: provider.categories,
            searchController: _searchController,
          ),
          Expanded(child: _DashboardBody(provider: provider)),
        ],
      ),
    );
  }
}

/// Bagian utama dashboard yang bisa di-scroll bersama:
/// ringkasan statistik + chart, lalu daftar laporan.
class _DashboardBody extends StatelessWidget {
  final ReportProvider provider;

  const _DashboardBody({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.loading && provider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.reports.isEmpty) {
      return EmptyState(
        kind: EmptyStateKind.error,
        title: 'Gagal memuat data',
        subtitle: provider.error,
        action: FilledButton.tonalIcon(
          onPressed: provider.loadReports,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadReports();
        await provider.loadStats();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _StatsSection(stats: provider.stats)),
          if (provider.reports.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Tidak ada laporan',
                subtitle: 'Tidak ada laporan yang cocok dengan filter.',
              ),
            )
          else
            SliverList.builder(
              itemCount: provider.reports.length,
              itemBuilder: (context, index) {
                final report = provider.reports[index];
                return ReportCard(
                  report: report,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportDetailScreen(reportId: report.id),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const _StatsSection({this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byStatus = stats?['by_status'] as List<dynamic>? ?? const [];
    final byCategory = stats?['by_category'] as List<dynamic>? ?? const [];
    final byMonth = stats?['by_month'] as List<dynamic>? ?? const [];
    final total = (stats?['total'] as num?)?.toInt() ?? 0;

    final statusCounts = <String, int>{
      for (final item in byStatus)
        (item as Map<String, dynamic>)['status'] as String:
            (item['total'] as num).toInt(),
    };

    final categories = byCategory
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final months = byMonth
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan', style: theme.textTheme.titleMedium),
              Text(
                '$total total laporan',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final status in const [
                  'dilaporkan',
                  'diverifikasi',
                  'diproses',
                  'selesai',
                ])
                  _StatusCountCard(
                    status: status,
                    label: AppColors.statusLabel(status),
                    count: statusCounts[status] ?? 0,
                  ),
              ],
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Laporan per Kategori', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            CategoryBars(data: categories),
          ],
          if (months.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Tren 6 Bulan Terakhir', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            MonthBars(data: months),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatusCountCard extends StatelessWidget {
  final String status;
  final String label;
  final int count;

  const _StatusCountCard({
    required this.status,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.statusColor(status);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _FilterSection extends StatefulWidget {
  final List<Category> categories;
  final TextEditingController searchController;

  const _FilterSection({
    required this.categories,
    required this.searchController,
  });

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  String? _status;
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: widget.searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari judul, lokasi, deskripsi...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: widget.searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        provider.setSearchQuery('');
                      },
                    ),
            ),
            onSubmitted: provider.setSearchQuery,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Semua')),
                    DropdownMenuItem(value: 'dilaporkan', child: Text('Dilaporkan')),
                    DropdownMenuItem(value: 'diverifikasi', child: Text('Diverifikasi')),
                    DropdownMenuItem(value: 'diproses', child: Text('Diproses')),
                    DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value);
                    provider.setFilterStatus(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Semua'),
                    ),
                    ...widget.categories
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            )),
                  ],
                  onChanged: (value) {
                    setState(() => _categoryId = value);
                    provider.setFilterCategory(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
