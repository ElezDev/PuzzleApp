import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:puzlessapp/l10n/app_strings.dart';
import 'package:puzlessapp/providers/app_provider.dart';
import 'package:puzlessapp/screens/games/hangman_screen.dart';

class _FakeAppProvider extends AppProvider {
  @override
  Future<void> recordGame({
    required String gameType,
    required String difficulty,
    required int score,
    int? timeSeconds,
    required bool won,
  }) async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(1 + 1, 2);
  });

  testWidgets('Hangman screen renders and accepts letters', (
    WidgetTester tester,
  ) async {
    final provider = _FakeAppProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: AppStrings.localizationsDelegates,
          home: HangmanScreen(initialDifficulty: 'Fácil'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Adivina la palabra'), findsOneWidget);
    expect(find.text('Elige una letra'), findsOneWidget);

    await tester.tap(find.text('A'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
