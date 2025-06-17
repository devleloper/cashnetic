import 'package:cashnetic/models/category/category_model.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_state.dart';

class TransactionListByCategoryScreen extends StatelessWidget {
  final CategoryModel category;
  const TransactionListByCategoryScreen({super.key, required this.category});

  TransactionModel _mapToTransactionModel(dynamic transaction) {
    return TransactionModel(
      id: transaction.id,
      categoryId: transaction.categoryId,
      account: 'Account', // TODO: Get from account repository
      categoryIcon: '💰', // TODO: Get from category
      categoryTitle: category.name,
      type: transaction.amount > 0
          ? TransactionType.income
          : TransactionType.expense,
      comment: transaction.comment,
      amount: transaction.amount.abs(),
      transactionDate: transaction.timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(category.name),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoaded) {
            final txns = state.txByCategory[category.id] ?? [];
            return ListView.separated(
              itemCount: txns.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = txns[i];
                final txModel = _mapToTransactionModel(t);
                return MyItemListTile(
                  e: txModel,
                  bgColor: Colors.green.shade50,
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
