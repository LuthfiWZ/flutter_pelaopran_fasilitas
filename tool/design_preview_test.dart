// Test preview desain (SEMENTARA): merender layar ke PNG untuk review visual.
// Jalankan: flutter test --update-goldens test/design_preview_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/models/report.dart';
import 'package:flutter_app/models/status_log.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/report_provider.dart';
import 'package:flutter_app/screens/create_report_screen.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/report_detail_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class _FakeAuth extends AuthProvider {
  _FakeAuth(this._user);
  final User _user;

  @override
  AuthStatus get status => AuthStatus.authenticated;
  @override
  User? get user => _user;
  @override
  bool get loading => false;
  @override
  String? get error => null;
  @override
  bool get isAdmin => _user.isAdmin;
}

class _FakeReports extends ReportProvider {
  _FakeReports({
    required this.reportsOverride,
    this.categoriesOverride = const [],
  });
  final List<Report> reportsOverride;
  final List<Category> categoriesOverride;

  @override
  List<Report> get reports => reportsOverride;
  @override
  List<Category> get categories => categoriesOverride;
  @override
  bool get loading => false;
  @override
  String? get error => null;
  @override
  Future<void> loadReports() async {}
  @override
  Future<void> loadCategories() async {}
  @override
  Future<void> loadStats() async {}
  @override
  Future<Report?> getReportById(int id) async =>
      reportsOverride.firstWhere((r) => r.id == id);
}

Report _buildReport(int id) {
  return Report(
    id: id,
    userId: 2,
    reporterName: 'User Demo',
    category: Category(id: 1, name: 'Listrik'),
    title: 'Lampu koridor lantai 2 mati',
    description:
        'Lampu di koridor lantai 2 mati sejak kemarin, membuat area gelap '
        'dan membahayakan mahasiswa yang lewat.',
    location: 'Gedung A',
    building: 'Gedung A',
    room: 'Koridor Lt 2',
    status: 'diproses',
    statusLabel: 'Diproses',
    timeline: [
      StatusLog(
        id: 1,
        status: 'dilaporkan',
        statusLabel: 'Dilaporkan',
        note: null,
        userName: 'User Demo',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      StatusLog(
        id: 2,
        status: 'diverifikasi',
        statusLabel: 'Diverifikasi',
        note: 'Laporan diverifikasi oleh petugas.',
        userName: 'Admin Fasilitas',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StatusLog(
        id: 3,
        status: 'diproses',
        statusLabel: 'Diproses',
        note: 'Teknisi sedang menangani perbaikan lampu.',
        userName: 'Admin Fasilitas',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now(),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
    // Muat font asli; jangan di-await (di lingkungan test tidak dijamin
    // selesai) — cukup dipicu agar bila tersedia ikut ter-render.
    for (final family in ['SpaceGrotesk', 'Inter', 'JetBrainsMono']) {
      final bytes = await rootBundle.load('assets/fonts/$family-Variable.ttf');
      final loader = FontLoader(family)..addFont(Future.value(bytes));
      loader.load();
    }
  });

  testWidgets('preview: login', (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('preview/login.png'),
    );
  });

  testWidgets('preview: home', (tester) async {
    _setPhone(tester);
    final user = User(id: 2, name: 'User Demo', email: 'user@test.com', role: 'user');
    await tester.pumpWidget(_wrap(const HomeScreen(), user: user));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('preview/home.png'),
    );
  });

  testWidgets('preview: form langkah 1', (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(_wrap(const CreateReportScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(CreateReportScreen),
      matchesGoldenFile('preview/form.png'),
    );
  });

  testWidgets('preview: detail (admin)', (tester) async {
    _setPhone(tester);
    final admin = User(id: 1, name: 'Admin Fasilitas', email: 'admin@test.com', role: 'admin');
    await tester.pumpWidget(
      _wrap(const ReportDetailScreen(reportId: 7), user: admin),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(ReportDetailScreen),
      matchesGoldenFile('preview/detail.png'),
    );
  });
}

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Widget _wrap(Widget home, {User? user}) {
  final currentUser = user ??
      User(id: 2, name: 'User Demo', email: 'user@test.com', role: 'user');
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
        value: _FakeAuth(currentUser),
      ),
      ChangeNotifierProvider<ReportProvider>.value(
        value: _FakeReports(
          reportsOverride: [
            _buildReport(7),
            _buildReport(6),
            _buildReport(5),
          ],
          categoriesOverride: [
            Category(id: 1, name: 'Listrik'),
            Category(id: 2, name: 'AC'),
            Category(id: 3, name: 'Sanitasi'),
            Category(id: 4, name: 'Furniture'),
            Category(id: 5, name: 'Jaringan'),
          ],
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    ),
  );
}