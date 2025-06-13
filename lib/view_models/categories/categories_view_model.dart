import 'package:cashnetic/models/category/category_model.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:flutter/material.dart';

import '../../repositories/categories/categories_repositroy.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository categoriesRepo;
  final TransactionsRepository txRepo;

  List<CategoryModel> _categories = [];
  final Map<int, List<TransactionModel>> _txByCat = {};

  CategoriesViewModel({required this.categoriesRepo, required this.txRepo});

  List<CategoryModel> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await categoriesRepo.fetchAll();
    notifyListeners();
  }

  Future<void> loadTransactionsFor(int categoryId) async {
    final txs = await txRepo.loadByCategory(categoryId);
    _txByCat[categoryId] = txs;
    notifyListeners();
  }

  List<TransactionModel> transactionsByCategory(int categoryId) {
    return _txByCat[categoryId] ?? [];
  }

  Future<void> addCategory(CategoryModel category) async {
    await categoriesRepo.addCategoryModel(category);
    await loadCategories();
  }

  Future<bool> deleteCategory(int categoryId) async {
    final result = await categoriesRepo.deleteCategory(categoryId);
    await loadCategories();
    return result;
  }

  CategoryModel? getCategoryById(int id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => const CategoryModel(
        id: -1,
        name: 'Неизвестно',
        emoji: '❓',
        isIncome: false,
      ),
    );
  }
}
