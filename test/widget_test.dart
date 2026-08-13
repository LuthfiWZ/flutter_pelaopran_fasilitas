import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_app/widgets/status_tag.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('StatusTag menampilkan label status uppercase', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusTag(status: 'selesai'),
        ),
      ),
    );

    expect(find.text('SELESAI'), findsOneWidget);
  });

  testWidgets('AppColors memetakan status ke warna bermakna', (tester) async {
    expect(AppColors.statusColor('dilaporkan'), AppColors.rust);
    expect(AppColors.statusColor('diverifikasi'), AppColors.brass);
    expect(AppColors.statusColor('diproses'), AppColors.steel);
    expect(AppColors.statusColor('selesai'), AppColors.moss);
  });

  testWidgets('App boot tanpa token: masuk halaman login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PelaporanApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
