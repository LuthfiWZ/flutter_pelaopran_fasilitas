import 'package:flutter/material.dart';
import 'package:flutter_app/models/category.dart';
import 'package:flutter_app/providers/report_provider.dart';
import 'package:flutter_app/screens/create_report_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:provider/provider.dart';

class _FakeReports extends ReportProvider {
  bool createReportCalled = false;
  int? submittedCategoryId;
  String? submittedTitle;
  XFile? submittedPhoto;

  @override
  List<Category> get categories => [
        Category(id: 1, name: 'Listrik'),
        Category(id: 2, name: 'AC'),
      ];

  @override
  Future<bool> createReport({
    required int categoryId,
    required String title,
    required String description,
    required String location,
    String? building,
    String? room,
    XFile? photo,
  }) async {
    createReportCalled = true;
    submittedCategoryId = categoryId;
    submittedTitle = title;
    submittedPhoto = photo;
    return true;
  }
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateReportScreen()),
          ),
          child: const Text('open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('mengirim laporan dari form 3 langkah berhasil', (tester) async {
    final fake = _FakeReports();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ReportProvider>.value(value: fake),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const _Launcher(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Langkah 1: pilih kategori lalu Lanjut
    await tester.tap(find.text('Listrik'));
    await tester.pump();
    expect(fake.submittedCategoryId, isNull, reason: 'belum submit');
    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    // seharusnya sudah di langkah 2 (form detail tampil)
    expect(find.text('Judul laporan'), findsOneWidget);

    // Langkah 2: isi detail lalu Lanjut
    await tester.enterText(find.byType(TextFormField).at(0), 'Lampu mati');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lampu koridor mati');
    await tester.enterText(find.byType(TextFormField).at(2), 'Gedung A');
    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    // Langkah 3: review tampil (SectionLabel dirender uppercase)
    expect(find.text('PERIKSA SEBELUM KIRIM'), findsOneWidget);

    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(fake.createReportCalled, isTrue);
    expect(fake.submittedCategoryId, 1);
    expect(fake.submittedTitle, 'Lampu mati');
  });

  testWidgets('lanjut tanpa kategori memunculkan peringatan', (tester) async {
    final fake = _FakeReports();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ReportProvider>.value(value: fake),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const _Launcher(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Langkah 1 tanpa memilih kategori
    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    expect(find.text('Pilih kategori kerusakan terlebih dahulu'), findsOneWidget);
    expect(fake.createReportCalled, isFalse);
  });
}
