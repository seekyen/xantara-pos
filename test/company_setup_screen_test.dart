import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/features/setup/company_setup_screen.dart';
import 'package:pos_app/features/setup/terminal_enrollment_screen.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_providers.dart';

void main() {
  testWidgets('phone enrollment scrolls and requires review', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: TerminalEnrollmentScreen())));
    await tester.scrollUntilVisible(
        find.text('Enroll and create local owner'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(
                FilledButton, 'Enroll and create local owner'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('phone setup scrolls, validates and requires explicit review',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase(NativeDatabase.memory(), requireRegistration: true);
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: CompanySetupScreen())));
    expect(find.text('Company and terminal registration'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Save company and owner'), 500,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Save company and owner'))
            .onPressed,
        isNull);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Save company and owner'));
    await tester.tap(find.text('Save company and owner'));
    await tester.pump();
    expect(find.text('Required'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('demo action explicitly requests the isolated demo workspace',
      (tester) async {
    bool? mode;
    await tester.pumpWidget(ProviderScope(overrides: [
      switchInstallationProvider.overrideWithValue((demo) async {
        mode = demo;
      })
    ], child: const MaterialApp(home: CompanySetupScreen())));
    await tester.tap(find.text('Use demo workspace instead'));
    await tester.pump();
    expect(mode, isTrue);
  });
}
