import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/domain/entities/category.dart';
import '../widgets/category_list_tile.dart';
import 'transaction_list_by_category_screen.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(InitCategoriesWithTransactions());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      route.addScopedWillPopCallback(() async {
        context.read<CategoriesBloc>().add(InitCategoriesWithTransactions());
        return true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CategoriesError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }
        final txByCategory = state.txByCategory;
        final categories =
            state.categories
                .where(
                  (c) =>
                      _search.isEmpty ||
                      c.name.toLowerCase().contains(_search.toLowerCase()),
                )
                .toList()
              ..sort(
                (a, b) => (txByCategory[b.id]?.length ?? 0).compareTo(
                  txByCategory[a.id]?.length ?? 0,
                ),
              );
        return Scaffold(
          appBar: AppBar(title: const Text('Категории')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Найти категорию',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final txCount = txByCategory[cat.id]?.length ?? 0;
                    return CategoryListTile(
                      category: cat,
                      txCount: txCount,
                      onTap: () async {
                        context.read<CategoriesBloc>().add(
                          LoadTransactionsForCategory(cat.id),
                        );
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionListByCategoryScreen(
                              category: Category(
                                id: cat.id,
                                name: cat.name,
                                emoji: cat.emoji,
                                isIncome: cat.isIncome,
                                color: cat.color,
                              ),
                            ),
                          ),
                        );
                        context.read<CategoriesBloc>().add(
                          LoadTransactionsForCategory(cat.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
