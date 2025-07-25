import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashnetic/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Switch Tests', () {
    testWidgets('Switch system theme toggle test', (WidgetTester tester) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle();

      // Ждем загрузки главного экрана
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку настроек (ищем иконку настроек)
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Ищем переключатель системной темы
        final systemThemeSwitch = find.byWidgetPredicate(
          (widget) => widget is SwitchListTile && 
                      widget.title is Text && 
                      (widget.title as Text).data == 'Системная тема',
        );

        if (systemThemeSwitch.evaluate().isNotEmpty) {
          // Проверяем начальное состояние переключателя
          final switchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          final initialValue = switchWidget.value;
          
          print('Initial theme switch value: $initialValue');

          // Переключаем системную тему
          await tester.tap(systemThemeSwitch);
          await tester.pumpAndSettle();

          // Проверяем, что значение изменилось
          final newSwitchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          final newValue = newSwitchWidget.value;
          
          print('New theme switch value: $newValue');
          
          // Проверяем, что значение действительно изменилось
          expect(newValue, isNot(equals(initialValue)));

          // Переключаем обратно
          await tester.tap(systemThemeSwitch);
          await tester.pumpAndSettle();

          // Проверяем, что вернулись к исходному состоянию
          final finalSwitchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          final finalValue = finalSwitchWidget.value;
          
          print('Final theme switch value: $finalValue');
          
          expect(finalValue, equals(initialValue));
        } else {
          print('System theme switch not found');
        }
      } else {
        print('Settings tab not found');
      }
    });

    testWidgets('Theme persistence test', (WidgetTester tester) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle();

      // Ждем загрузки главного экрана
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим в настройки (ищем иконку настроек)
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Ищем переключатель системной темы
        final systemThemeSwitch = find.byWidgetPredicate(
          (widget) => widget is SwitchListTile && 
                      widget.title is Text && 
                      (widget.title as Text).data == 'Системная тема',
        );

        if (systemThemeSwitch.evaluate().isNotEmpty) {
          // Запоминаем начальное состояние
          final initialSwitchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          final initialValue = initialSwitchWidget.value;

          // Переключаем тему
          await tester.tap(systemThemeSwitch);
          await tester.pumpAndSettle();

          // Перезапускаем приложение
          app.main();
          await tester.pumpAndSettle();

          // Снова переходим в настройки
          final newSettingsTab = find.byIcon(Icons.settings);
          if (newSettingsTab.evaluate().isNotEmpty) {
            await tester.tap(newSettingsTab);
            await tester.pumpAndSettle();

            // Проверяем, что настройка сохранилась
            final newSystemThemeSwitch = find.byWidgetPredicate(
              (widget) => widget is SwitchListTile && 
                          widget.title is Text && 
                          (widget.title as Text).data == 'Системная тема',
            );

            if (newSystemThemeSwitch.evaluate().isNotEmpty) {
              final newSwitchWidget = tester.widget<SwitchListTile>(newSystemThemeSwitch);
              final newValue = newSwitchWidget.value;
              
              // Проверяем, что настройка сохранилась
              expect(newValue, isNot(equals(initialValue)));
            }
          }
        }
      }
    });

    testWidgets('Theme visual change test', (WidgetTester tester) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle();

      // Ждем загрузки главного экрана
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Запоминаем начальный цвет фона
      final initialScaffold = find.byType(Scaffold);
      if (initialScaffold.evaluate().isNotEmpty) {
        final initialScaffoldWidget = tester.widget<Scaffold>(initialScaffold);
        final initialBackgroundColor = initialScaffoldWidget.backgroundColor;

        // Переходим в настройки (ищем иконку настроек)
        final settingsTab = find.byIcon(Icons.settings);
        if (settingsTab.evaluate().isNotEmpty) {
          await tester.tap(settingsTab);
          await tester.pumpAndSettle();

          // Ищем переключатель системной темы
          final systemThemeSwitch = find.byWidgetPredicate(
            (widget) => widget is SwitchListTile && 
                        widget.title is Text && 
                        (widget.title as Text).data == 'Системная тема',
          );

          if (systemThemeSwitch.evaluate().isNotEmpty) {
            // Переключаем тему
            await tester.tap(systemThemeSwitch);
            await tester.pumpAndSettle();

            // Возвращаемся на главный экран
            final homeTab = find.text('Home');
            if (homeTab.evaluate().isNotEmpty) {
              await tester.tap(homeTab);
              await tester.pumpAndSettle();

              // Проверяем, что цвет фона изменился
              final newScaffold = find.byType(Scaffold);
              if (newScaffold.evaluate().isNotEmpty) {
                final newScaffoldWidget = tester.widget<Scaffold>(newScaffold);
                final newBackgroundColor = newScaffoldWidget.backgroundColor;

                // Проверяем, что цвет изменился (если тема действительно переключилась)
                if (initialBackgroundColor != null && newBackgroundColor != null) {
                  expect(newBackgroundColor, isNot(equals(initialBackgroundColor)));
                }
              }
            }
          }
        }
      }
    });

    testWidgets('Theme switch accessibility test', (WidgetTester tester) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle();

      // Ждем загрузки главного экрана
      await tester.pumpAndSettle(const Duration(seconds: 3));

              // Переходим в настройки (ищем иконку настроек)
        final settingsTab = find.byIcon(Icons.settings);
        if (settingsTab.evaluate().isNotEmpty) {
          await tester.tap(settingsTab);
          await tester.pumpAndSettle();

        // Ищем переключатель системной темы
        final systemThemeSwitch = find.byWidgetPredicate(
          (widget) => widget is SwitchListTile && 
                      widget.title is Text && 
                      (widget.title as Text).data == 'Системная тема',
        );

        if (systemThemeSwitch.evaluate().isNotEmpty) {
          // Проверяем, что переключатель доступен для взаимодействия
          final switchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          
          // Проверяем наличие заголовка
          expect(switchWidget.title, isA<Text>());
          
          // Проверяем, что переключатель активен
          expect(switchWidget.onChanged, isNotNull);

          // Проверяем, что переключатель можно нажать
          await tester.tap(systemThemeSwitch);
          await tester.pumpAndSettle();

          // Проверяем, что после нажатия переключатель все еще доступен
          final newSwitchWidget = tester.widget<SwitchListTile>(systemThemeSwitch);
          expect(newSwitchWidget.onChanged, isNotNull);
        }
      }
    });
  });
} 