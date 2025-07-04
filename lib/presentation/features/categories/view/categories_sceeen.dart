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
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _search = '';
  late final TextEditingController _controller;
  DriftCategoryRepository? _driftRepo;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    context.read<CategoriesBloc>().add(InitCategoriesWithTransactions());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _driftRepo = RepositoryProvider.of<DriftCategoryRepository>(
        context,
        listen: false,
      );
      final lastQuery = await _driftRepo?.getLastSearchQuery();
      if (lastQuery != null && lastQuery.isNotEmpty) {
        _controller.text = lastQuery;
        setState(() => _search = lastQuery);
        context.read<CategoriesBloc>().add(SearchCategories(lastQuery));
      }
    });
    _controller.addListener(() async {
      final val = _controller.text;
      if (val.isEmpty && _search.isNotEmpty) {
        setState(() => _search = '');
        context.read<CategoriesBloc>().add(SearchCategories(''));
        await _driftRepo?.deleteSearchQuery();
      } else {
        setState(() => _search = val);
        context.read<CategoriesBloc>().add(SearchCategories(val));
        await _driftRepo?.saveSearchQuery(val);
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
