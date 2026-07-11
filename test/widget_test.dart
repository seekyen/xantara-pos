import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/app.dart';
import 'package:pos_app/local/database.dart';
import 'package:pos_app/local/database_providers.dart';
import 'package:pos_app/local/database_seed.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await seedDatabaseIfEmpty(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const PosApp(),
      ),
    );
    // Splash intentionally holds for three seconds before navigating.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
