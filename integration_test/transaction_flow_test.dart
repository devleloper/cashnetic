import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashnetic/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add transaction flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // TODO: Найти и нажать кнопку добавления транзакции
    // TODO: Заполнить форму (сумма, категория и т.д.)
    // TODO: Сохранить транзакцию
    // TODO: Проверить, что транзакция появилась в списке

    // Пример (заменить на реальные ключи/тексты):
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pumpAndSettle();
    // await tester.enterText(find.byKey(Key('amountField')), '123');
    // await tester.tap(find.text('Groceries'));
    // await tester.tap(find.text('Save'));
    // await tester.pumpAndSettle();
    // expect(find.text('123'), findsOneWidget);
  });
} 