import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

/// Pemilih foto bergaya "titik bukti": area dropzone dashed dengan label
/// mono, preview dengan tombol ganti/hapus.
///
/// Berjalan di semua platform (Android/iOS/web): file disimpan sebagai
/// [XFile] dan preview memakai bytes, bukan path filesystem.
class PhotoPickerField extends StatefulWidget {
  final XFile? initialFile;
  final ValueChanged<XFile?> onChanged;
  final String label;

  const PhotoPickerField({
    super.key,
    required this.onChanged,
    this.initialFile,
    this.label = 'FOTO (OPSIONAL)',
  });

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  final ImagePicker _picker = ImagePicker();
  XFile? _file;
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _file = widget.initialFile;
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _file = picked;
      _bytes = bytes;
    });
    widget.onChanged(_file);
  }

  Future<void> _showOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'SUMBER FOTO',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: AppColors.stone,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dengan kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) await _pick(source);
  }

  void _clear() {
    setState(() {
      _file = null;
      _bytes = null;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.stone,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        if (_file != null && _bytes != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.memory(
                  _bytes!,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _previewFallback(theme),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton.filledTonal(
                  onPressed: _clear,
                  icon: const Icon(Icons.close),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FilledButton.tonalIcon(
                  onPressed: _showOptions,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Ganti'),
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: _showOptions,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: AppColors.stone.withValues(alpha: 0.5),
                  width: 1.4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.ember.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 26,
                      color: AppColors.ember,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Foto kerusakan',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'KAMERA ATAU GALERI',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                      color: AppColors.stone,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _previewFallback(ThemeData theme) {
    return Container(
      height: 190,
      color: AppColors.fog,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: AppColors.stone, size: 40),
    );
  }
}
