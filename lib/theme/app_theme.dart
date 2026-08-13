import 'package:flutter/material.dart';

/// ============================================================================
/// TOKEN DESAIN — "Kerja Perawatan Fasilitas" (Graphite & Ember)
/// ----------------------------------------------------------------------------
/// Identitas visual dibangun dari kesan tim perawatan gedung: papan "work
/// order", pakaian kerja, dan material bangunan. Hangat, teknis, manusiawi —
/// bukan biru-ungu generik.
///
/// - Ember orange  = energi perbaikan; DIPAKAI HEMAT (tombol aksi + titik
///   aktif di timeline). Ini "satu risiko desain" yang disengaja.
/// - Graphite      = percaya diri & serius, "beton gelap".
/// - Bone          = kertas/beton hangat sebagai latar (bukan putih klinis).
/// - Warna status  = tiap tahap punya makna material, bukan merah/kuning/hijau
///   standar: Rust (rusak/menghambat), Brass (inspeksi), Steel (sedang
///   dikerjakan), Moss (tuntas & tenang).
/// ============================================================================
class AppColors {
  AppColors._();

  // Neutrals (bahan bangunan)
  static const bone = Color(0xFFF7F4EE); // latar utama — kertas/beton hangat
  static const fog = Color(0xFFEAE5DB); // permukaan sekunder & divider
  static const graphite = Color(0xFF20242B); // ink utama — "beton gelap"
  static const stone = Color(0xFF7C8189); // teks sekunder & border — "batu"

  // Brand / aksen tunggal
  static const ember = Color(0xFFE2531D); // energi perbaikan (CTA, titik aktif)

  // Status laporan — makna material
  static const rust = Color(0xFFC23B2E); // dilaporkan — ada kerusakan/menghambat
  static const brass = Color(0xFF9E6F12); // diverifikasi — tengah diperiksa (logam kuningan)
  static const steel = Color(0xFF2F6B92); // diproses — sedang dikerjakan (baja)
  static const moss = Color(0xFF3C7A4B); // selesai — tuntas, tenang (lumut)

  static const onEmber = Colors.white;

  static Color statusColor(String status) {
    return switch (status) {
      'dilaporkan' => rust,
      'diverifikasi' => brass,
      'diproses' => steel,
      'selesai' => moss,
      _ => stone,
    };
  }

  static String statusLabel(String status) {
    return switch (status) {
      'dilaporkan' => 'Dilaporkan',
      'diverifikasi' => 'Diverifikasi',
      'diproses' => 'Diproses',
      'selesai' => 'Selesai',
      _ => status,
    };
  }

  static IconData statusIcon(String status) {
    return switch (status) {
      'dilaporkan' => Icons.flag_outlined,
      'diverifikasi' => Icons.search_outlined,
      'diproses' => Icons.construction_outlined,
      'selesai' => Icons.check,
      _ => Icons.circle_outlined,
    };
  }
}

/// Skala sudut — bervariasi sesuai hierarki, bukan seragam.
/// - `tag`   : label teknis (tajam, kecil)
/// - `input` : field & chip
/// - `card`  : kartu konten (duduk nyaman)
/// - `panel` : panel hero / bottom sheet
class AppRadius {
  AppRadius._();

  static const tag = 6.0;
  static const input = 12.0;
  static const card = 20.0;
  static const panel = 28.0;
}

/// Irama spasi — variabel, bukan padding seragam.
class AppSpace {
  AppSpace._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Pairing font yang disengaja:
/// - SpaceGrotesk : display/heading — geometris-teknis, kesan "blueprint".
/// - Inter        : body — legibilitas tinggi untuk deskripsi panjang.
/// - JetBrainsMono: label data (nomor tiket, tanggal, status) — kesan
///                  "log perawatan / inspection report".
class AppFonts {
  AppFonts._();

  static const display = 'SpaceGrotesk';
  static const body = 'Inter';
  static const mono = 'JetBrainsMono';
}

/// Nomor tiket laporan, mis. `LP-0007`.
String ticketNumber(int id) => 'LP-${id.toString().padLeft(4, '0')}';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.ember).copyWith(
    primary: AppColors.ember,
    onPrimary: AppColors.onEmber,
    secondary: AppColors.graphite,
    onSecondary: Colors.white,
    error: AppColors.rust,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.graphite,
    surfaceContainer: AppColors.bone,
    surfaceContainerHigh: Colors.white,
    surfaceContainerHighest: AppColors.fog,
    outline: AppColors.stone.withValues(alpha: 0.4),
  );

  TextStyle display(double size, FontWeight weight, {double? height}) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: weight,
        height: height ?? 1.2,
        letterSpacing: -0.3,
      );

  TextStyle body(double size, FontWeight weight, {double? height}) => TextStyle(
        fontFamily: AppFonts.body,
        fontSize: size,
        fontWeight: weight,
        height: height ?? 1.5,
      );

  TextStyle mono(double size, FontWeight weight, {double spacing = 0.5}) =>
      TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
      );

  final textTheme = TextTheme(
    displayLarge: display(40, FontWeight.w700),
    displayMedium: display(34, FontWeight.w700),
    headlineLarge: display(30, FontWeight.w700),
    headlineMedium: display(26, FontWeight.w700),
    headlineSmall: display(23, FontWeight.w700),
    titleLarge: display(21, FontWeight.w700),
    titleMedium: display(17, FontWeight.w600),
    titleSmall: display(15, FontWeight.w600),
    bodyLarge: body(16, FontWeight.w400),
    bodyMedium: body(14, FontWeight.w400),
    bodySmall: body(13, FontWeight.w400),
    labelLarge: body(15, FontWeight.w600, height: 1.2),
    labelMedium: body(12, FontWeight.w500, height: 1.2),
    labelSmall: mono(10.5, FontWeight.w500, spacing: 1.1),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bone,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bone,
      foregroundColor: AppColors.graphite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: display(20, FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ember,
        foregroundColor: AppColors.onEmber,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: body(15, FontWeight.w600, height: 1.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.graphite,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        side: BorderSide(color: AppColors.graphite.withValues(alpha: 0.5)),
        shape: const StadiumBorder(),
        textStyle: body(15, FontWeight.w600, height: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ember,
        textStyle: body(14, FontWeight.w600, height: 1.2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.ember,
      foregroundColor: AppColors.onEmber,
      extendedTextStyle: TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: body(14, FontWeight.w500),
      hintStyle: body(14, FontWeight.w400)
          .copyWith(color: AppColors.stone.withValues(alpha: 0.8)),
      prefixIconColor: AppColors.stone,
      suffixIconColor: AppColors.stone,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.stone.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.stone.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.ember, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.rust.withValues(alpha: 0.8)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.fog,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.graphite,
      contentTextStyle: body(14, FontWeight.w500).copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.ember,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.bone,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.panel),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      textStyle: body(14, FontWeight.w500),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.stone.withValues(alpha: 0.35)),
      ),
    ),
  );
}
