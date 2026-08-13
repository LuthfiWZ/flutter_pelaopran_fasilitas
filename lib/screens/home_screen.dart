import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import 'create_report_screen.dart';
import 'notifications_screen.dart';
import 'report_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportProvider>();
      provider.loadReports();
      provider.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Saya'),
        actions: [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateReportScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
      body: Column(
        children: [
          _GreetingHeader(
            name: auth.user?.name ?? '',
            reports: provider.reports,
          ),
          Expanded(child: _ReportList(provider: provider)),
        ],
      ),
    );
  }
}

/// Header "meja kerja": sapaan + strip ringkasan status berwarna.
/// Strip ini membuat daftar laporan bisa dipindai: warna status di tepi
/// kartu + hitungan per status di header.
class _GreetingHeader extends StatelessWidget {
  final String name;
  final List<Report> reports;

  const _GreetingHeader({required this.name, required this.reports});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final counts = <String, int>{};
    for (final r in reports) {
      counts[r.status] = (counts[r.status] ?? 0) + 1;
    }

    const statuses = ['dilaporkan', 'diverifikasi', 'diproses', 'selesai'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: AppColors.stone.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.ember.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.tag * 2),
                ),
                child: Icon(
                  Icons.construction_outlined,
                  color: AppColors.ember,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $name', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Lacak progres perbaikan fasilitas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.stone,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < statuses.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 34,
                    color: AppColors.fog,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        Text(
                          '${counts[statuses[i]] ?? 0}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.statusColor(statuses[i]),
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppColors.statusLabel(statuses[i]).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 8.5,
                            letterSpacing: 0.8,
                            color: AppColors.stone,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  final ReportProvider provider;

  const _ReportList({required this.provider});

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

    if (provider.reports.isEmpty) {
      return EmptyState(
        title: 'Belum ada laporan',
        subtitle: 'Fasilitas rusak? Buat laporan pertama Anda — kami akan '
            'menelusuri dan memperbaikinya.',
        action: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateReportScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Buat laporan'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: provider.reports.length,
        itemBuilder: (context, index) {
          final report = provider.reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReportCard(
              report: report,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(reportId: report.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
