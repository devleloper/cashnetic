import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/generated/l10n.dart';
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    context.read<CategoriesBloc>().add(InitCategoriesWithTransactions());
    _controller.addListener(() {
      if (_controller.text.isEmpty && _search.isNotEmpty) {
        setState(() => _search = '');
        context.read<CategoriesBloc>().add(SearchCategories(''));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        final List<Category> categories = List<Category>.from(state.categories)
          ..sort(
            (a, b) => (txByCategory[b.id]?.length ?? 0).compareTo(
              txByCategory[a.id]?.length ?? 0,
            ),
          );
        return Scaffold(
          body: Column(
            children: [
              CategorySearchField(
                controller: _controller,
                onChanged: (v) {
                  setState(() => _search = v);
                  context.read<CategoriesBloc>().add(SearchCategories(v));
                },
              ),
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          S.of(context).noCategoriesFoundForYourQuery,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : CategoryList(
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
                                category: cat,
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
