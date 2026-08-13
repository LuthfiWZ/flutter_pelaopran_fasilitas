import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../utils/category_icon.dart';
import '../utils/formatters.dart';
import '../widgets/photo_picker_field.dart';
import '../widgets/photo_viewer.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_rail.dart';
import '../widgets/section_label.dart';
import '../widgets/status_tag.dart';
import '../widgets/timeline_view.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? _report;
  bool _loading = true;

  // State form update status (admin)
  String? _newStatus;
  final _noteController = TextEditingController();
  XFile? _progressFile;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<ReportProvider>();
    final report = await provider.getReportById(widget.reportId);
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
      if (report != null) _newStatus = report.status;
    });
  }

  Future<void> _submitStatus() async {
    if (_newStatus == null || _newStatus == _report!.status) {
      _showSnack('Pilih status baru atau tambahkan progres');
      return;
    }
    setState(() => _submitting = true);
    final provider = context.read<ReportProvider>();
    final success = await provider.updateStatus(
      reportId: widget.reportId,
      status: _newStatus!,
      note: _noteController.text.trim(),
      photo: _progressFile,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _noteController.clear();
      _progressFile = null;
    });
    if (success) {
      _showSnack('Status laporan diperbarui');
      _load();
    } else {
      _showSnack(provider.error ?? 'Gagal memperbarui status');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: const Text('Laporan akan dihapus beserta fotonya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<ReportProvider>();
    final success = await provider.deleteReport(widget.reportId);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      _showSnack(provider.error ?? 'Gagal menghapus');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (_report != null)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? _ErrorView(onRetry: _load)
              : _buildContent(context, _report!, auth.isAdmin),
    );
  }

  Widget _buildContent(BuildContext context, Report report, bool isAdmin) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header tiket ----
          Container(
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
                  children: [
                    Text(
                      ticketNumber(report.id),
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 11,
                        letterSpacing: 1,
                        color: AppColors.stone,
                      ),
                    ),
                    const Spacer(),
                    StatusTag(status: report.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(report.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                _MetaRow(
                  icon: categoryIconFor(report.category?.name ?? ''),
                  label: 'KATEGORI',
                  value: report.category?.name ?? '-',
                ),
                _MetaRow(
                  icon: Icons.person_outline,
                  label: 'PELAPOR',
                  value: report.reporterName ?? 'Anda',
                ),
                _MetaRow(
                  icon: Icons.place_outlined,
                  label: 'LOKASI',
                  value: report.fullLocation,
                ),
                _MetaRow(
                  icon: Icons.schedule,
                  label: 'DILAPORKAN',
                  value: Formatters.dateTime(report.createdAt),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.lg),

          // ---- Signature: Progress Rail ----
          const SectionLabel(text: 'Status Perbaikan'),
          const SizedBox(height: AppSpace.md),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.stone.withValues(alpha: 0.3)),
            ),
            child: ProgressRail(currentStatus: report.status),
          ),

          const SizedBox(height: AppSpace.lg),

          if (report.photoUrl.isNotEmpty) ...[
            const SectionLabel(text: 'Foto Laporan'),
            const SizedBox(height: AppSpace.sm),
            GestureDetector(
              onTap: () => PhotoViewer.show(context, report.photoUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.network(
                  report.photoUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 210,
                    color: AppColors.fog,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.stone,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ],

          const SectionLabel(text: 'Deskripsi'),
          const SizedBox(height: AppSpace.sm),
          Text(report.description, style: theme.textTheme.bodyLarge),

          const SizedBox(height: AppSpace.xl),

          const SectionLabel(text: 'Riwayat Perbaikan'),
          TimelineView(logs: report.timeline),

          if (isAdmin) ...[
            const SizedBox(height: AppSpace.lg),
            _AdminUpdatePanel(
              report: report,
              newStatus: _newStatus,
              onStatusChanged: (s) => setState(() => _newStatus = s),
              noteController: _noteController,
              progressPhoto: _progressFile,
              onPhotoChanged: (p) => setState(() => _progressFile = p),
              submitting: _submitting,
              onSubmit: _submitStatus,
            ),
          ],
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.stone),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 9.5,
                letterSpacing: 1,
                color: AppColors.stone,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel admin: pilih status baru sebagai tile berwarna (bukan dropdown),
/// + catatan + foto progres + tombol simpan.
class _AdminUpdatePanel extends StatelessWidget {
  final Report report;
  final String? newStatus;
  final ValueChanged<String> onStatusChanged;
  final TextEditingController noteController;
  final XFile? progressPhoto;
  final ValueChanged<XFile?> onPhotoChanged;
  final bool submitting;
  final VoidCallback onSubmit;

  const _AdminUpdatePanel({
    required this.report,
    required this.newStatus,
    required this.onStatusChanged,
    required this.noteController,
    required this.progressPhoto,
    required this.onPhotoChanged,
    required this.submitting,
    required this.onSubmit,
  });

  static const _statusOptions = [
    'dilaporkan',
    'diverifikasi',
    'diproses',
    'selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        borderRadius: BorderRadius.circular(AppRadius.panel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PEMBARUAN STATUS',
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 11,
              letterSpacing: 1.4,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in _statusOptions)
                _StatusOptionTile(
                  status: status,
                  selected: newStatus == status,
                  onTap: () => onStatusChanged(status),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Catatan / progres (opsional)',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.ember, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PhotoPickerField(
            label: 'FOTO PROGRES (OPSIONAL)',
            onChanged: onPhotoChanged,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Simpan Status',
            icon: Icons.save_outlined,
            loading: submitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _StatusOptionTile extends StatelessWidget {
  final String status;
  final bool selected;
  final VoidCallback onTap;

  const _StatusOptionTile({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final label = AppColors.statusLabel(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.25),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppColors.statusIcon(status), size: 14, color: color),
            const SizedBox(width: 7),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 9.5,
                letterSpacing: 1,
                color: selected ? color : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.rust),
          const SizedBox(height: 12),
          Text(
            'GAGAL MEMUAT LAPORAN',
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 11,
              letterSpacing: 1.2,
              color: AppColors.stone,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
