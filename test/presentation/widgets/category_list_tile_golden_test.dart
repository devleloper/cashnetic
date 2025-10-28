import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:cashnetic/domain/entities/category.dart';

void main() {
  testWidgets('CategoryListTile golden', (WidgetTester tester) async {
    final category = Category(
      id: 1,
      name: 'Groceries',
      emoji: '🛒',
      isIncome: false,
      color: '#E0E0E0',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CategoryListTile(
              category: category,
              onTap: () {},
              txCount: 5,
              amount: 1200.0,
              percent: 30.0,
              showPercent: true,
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(CategoryListTile),
      matchesGoldenFile('goldens/category_list_tile_groceries.png'),
    );
  });
} 