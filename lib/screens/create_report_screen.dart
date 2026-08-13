import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../utils/category_icon.dart';
import '../widgets/photo_picker_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_label.dart';

/// Form buat laporan 3 langkah: FOTO & KATEGORI → DETAIL → KIRIM.
/// Dibuat bertahap agar melapor terasa cepat dan tidak mengintimidasi:
/// satu fokus per langkah, review singkat sebelum kirim ("ticket preview").
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _step = 0;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();

  Category? _selectedCategory;
  XFile? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  bool get _isLastStep => _step == 2;

  void _next() {
    // Langkah 1 → pastikan kategori sudah dipilih
    if (_step == 0) {
      if (_selectedCategory == null) {
        _showSnack('Pilih kategori kerusakan terlebih dahulu');
        return;
      }
      setState(() => _step = 1);
      return;
    }

    // Langkah 2 → validasi field detail (Form hanya ada di langkah ini)
    if (_step == 1) {
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }
      setState(() => _step = 2);
      return;
    }

    // Langkah 3 → kirim
    _submit();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final provider = context.read<ReportProvider>();
    final success = await provider.createReport(
      categoryId: _selectedCategory!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      building: _buildingController.text.trim(),
      room: _roomController.text.trim(),
      photo: _photo,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      _showSnack('Laporan terkirim. Petugas akan segera menindaklanjuti.');
      Navigator.of(context).pop();
    } else {
      _showSnack(provider.error ?? 'Gagal mengirim laporan');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _StepIndicator(current: _step),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStep(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildPhotoAndCategory();
      case 1:
        return _buildDetail();
      default:
        return _buildReview();
    }
  }

  // ---- Langkah 1: foto + kategori ----
  Widget _buildPhotoAndCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoPickerField(onChanged: (file) => _photo = file),
        const SizedBox(height: AppSpace.lg),
        const SectionLabel(text: 'Kategori Kerusakan'),
        const SizedBox(height: AppSpace.sm),
        _CategoryGrid(
          categories: context.watch<ReportProvider>().categories,
          selected: _selectedCategory,
          onSelect: (c) => setState(() => _selectedCategory = c),
        ),
      ],
    );
  }

  // ---- Langkah 2: detail ----
  Widget _buildDetail() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(text: 'Detail Kerusakan'),
          const SizedBox(height: AppSpace.md),
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Judul laporan',
              hintText: 'Contoh: Lampu koridor mati',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: AppSpace.md),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Deskripsi kerusakan',
              hintText: 'Jelaskan detail kerusakan yang terjadi',
              alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Deskripsi wajib diisi'
                : null,
          ),
          const SizedBox(height: AppSpace.lg),
          const SectionLabel(text: 'Lokasi'),
          const SizedBox(height: AppSpace.md),
          TextFormField(
            controller: _locationController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Lokasi',
              hintText: 'Contoh: Gedung A',
              prefixIcon: Icon(Icons.place_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Lokasi wajib diisi' : null,
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _buildingController,
                  decoration: const InputDecoration(
                    labelText: 'Gedung (opsional)',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm + 4),
              Expanded(
                child: TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Ruangan (opsional)',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Langkah 3: review / "ticket preview" ----
  Widget _buildReview() {
    final theme = Theme.of(context);
    final category = _selectedCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Periksa Sebelum Kirim'),
        const SizedBox(height: AppSpace.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.stone.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'TIKET BARU',
                    style: const TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: AppColors.stone,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    category == null
                        ? Icons.build_outlined
                        : categoryIconFor(category.name),
                    size: 18,
                    color: AppColors.ember,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _titleController.text.trim().isEmpty
                    ? '—'
                    : _titleController.text.trim(),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _ReviewRow(label: 'KATEGORI', value: category?.name ?? '-'),
              _ReviewRow(label: 'LOKASI', value: _locationController.text.trim().isEmpty ? '-' : _locationController.text.trim()),
              _ReviewRow(
                label: 'GEDUNG / RUANG',
                value: [
                  _buildingController.text.trim(),
                  _roomController.text.trim(),
                ].where((e) => e.isNotEmpty).join(' · ').isEmpty
                    ? '-'
                    : [
                        _buildingController.text.trim(),
                        _roomController.text.trim(),
                      ].where((e) => e.isNotEmpty).join(' · '),
              ),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  child: FutureBuilder<Uint8List>(
                    future: _photo!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(
                        height: 140,
                        color: AppColors.fog,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const Divider(height: 28),
              Text(
                _descriptionController.text.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.stone,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bone,
        border: Border(top: BorderSide(color: AppColors.fog)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                child: const Text('Kembali'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: _isLastStep ? 'Kirim Laporan' : 'Lanjut',
              icon: _isLastStep ? Icons.send : Icons.arrow_forward,
              loading: _submitting,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;

  const _StepIndicator({required this.current});

  static const _labels = ['LAPOR', 'DETAIL', 'KIRIM'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: i <= current
                          ? AppColors.ember
                          : AppColors.stone.withValues(alpha: 0.3),
                    ),
                  ),
                _StepNode(
                  number: '0${i + 1}',
                  label: _labels[i],
                  done: i < current,
                  active: i == current,
                ),
                if (i < _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: i + 1 <= current
                          ? AppColors.ember
                          : AppColors.stone.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  final String number;
  final String label;
  final bool done;
  final bool active;

  const _StepNode({
    required this.number,
    required this.label,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done || active ? AppColors.ember : Colors.white,
            shape: BoxShape.circle,
            border: done || active
                ? null
                : Border.all(color: AppColors.stone.withValues(alpha: 0.5)),
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  number,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.stone,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 8.5,
            letterSpacing: 1,
            color: active ? AppColors.ember : AppColors.stone,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final category in categories)
          _CategoryTile(
            category: category,
            selected: selected?.id == category.id,
            onTap: () => onSelect(category),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ember : AppColors.stone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ember.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: selected ? AppColors.ember : AppColors.stone.withValues(alpha: 0.4),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIconFor(category.name),
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? AppColors.ember : AppColors.graphite,
                  ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: AppColors.ember),
            ],
          ],
        ),
      ),
    );
  }
}
