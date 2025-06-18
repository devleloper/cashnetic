import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    context.read<CategoriesBloc>().add(LoadCategories());
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
        final categories = state.categories
            .where(
              (c) =>
                  _search.isEmpty ||
                  c.name.toLowerCase().contains(_search.toLowerCase()),
            )
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Категории')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Найти категорию',
                    prefixIcon: Icon(Icons.search),
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
                    return CategoryListTile(
                      category: cat,
                      onTap: () async {
                        context.read<CategoriesBloc>().add(
                          LoadTransactionsForCategory(cat.id),
                        );
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionListByCategoryScreen(category: cat),
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
