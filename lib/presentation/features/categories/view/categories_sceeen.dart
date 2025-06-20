import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_list_by_category_screen.dart';
import '../widgets/category_search_field.dart';
import '../widgets/category_list.dart';

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
              CategorySearchField(
                value: _search,
                onChanged: (v) => setState(() => _search = v),
              ),
              Expanded(
                child: CategoryList(
                  categories: categories,
                  txByCategory: txByCategory,
                  onCategoryTap: (cat) async {
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
