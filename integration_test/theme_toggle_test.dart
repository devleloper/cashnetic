import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashnetic/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Theme toggle changes app background', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Перейти на вкладку Settings по тексту (нижняя навигация)
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Найти переключатель 'Системная тема' и переключить его
    final systemThemeSwitch = find.widgetWithText(SwitchListTile, 'Системная тема');
    expect(systemThemeSwitch, findsOneWidget);
    // Получить текущее состояние
    final SwitchListTile tile = tester.widget(systemThemeSwitch);
    final bool wasEnabled = tile.value;
    // Переключить
    await tester.tap(systemThemeSwitch);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Проверить, что фон изменился (например, стал тёмным)
    final scaffoldFinder = find.byType(Scaffold).last;
    final Scaffold scaffold = tester.widget(scaffoldFinder);
    final Color? bgColor = scaffold.backgroundColor;
    expect(bgColor, isNotNull);

    // Переключить обратно
    await tester.tap(systemThemeSwitch);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final Scaffold scaffold2 = tester.widget(scaffoldFinder);
    final Color? bgColor2 = scaffold2.backgroundColor;
    expect(bgColor2, isNotNull);
    expect(bgColor2 != bgColor, true);
  });
} 