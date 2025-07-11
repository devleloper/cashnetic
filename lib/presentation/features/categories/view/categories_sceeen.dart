import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_list_by_category_screen.dart';
import '../widgets/category_list.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'package:cashnetic/presentation/widgets/shimmer_placeholder.dart';
import 'dart:async';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _search = '';
  late final TextEditingController _controller;
  SyncStatus? _lastSyncStatus;
  Completer<void>? _refreshCompleter;

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
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    syncStatusNotifier.removeListener(_onSyncStatusChanged);
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
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(context);
    syncStatusNotifier.removeListener(_onSyncStatusChanged); // just in case
    syncStatusNotifier.addListener(_onSyncStatusChanged);
  }

  void _onSyncStatusChanged() {
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    if (_lastSyncStatus == syncStatusNotifier.status) return;
    _lastSyncStatus = syncStatusNotifier.status;
    if (syncStatusNotifier.status == SyncStatus.online) {
      if (mounted) {
        context.read<CategoriesBloc>().add(InitCategoriesWithTransactions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        // RefreshIndicator: complete only on Loaded/Error
        if (_refreshCompleter != null &&
            (state is CategoriesLoaded || state is CategoriesError)) {
          _refreshCompleter?.complete();
          _refreshCompleter = null;
        }
        if (state is CategoriesLoading) {
          return const Scaffold(body: ShimmerCategoryListPlaceholder());
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
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 1. Background content — category list
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshCompleter = Completer<void>();
                    context.read<CategoriesBloc>().add(
                      InitCategoriesWithTransactions(),
                    );
                    return _refreshCompleter!.future;
                  },
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
              ),
              // 2. LiquidGlass above content, SearchField above LiquidGlass
              Positioned(
                top: 24,
                left: 16,
                right: 16,
                child: LiquidSearchField(
                  thickness: 18,
                  blur: 4,
                  blend: 0.5,
                  lightIntensity: 2,
                  lightAngle: 180,
                  refractiveIndex: 2,
                  glassColor: const Color.fromARGB(19, 0, 0, 0),
                  controller: _controller,
                  onChanged: (v) {
                    setState(() => _search = v);
                    context.read<CategoriesBloc>().add(SearchCategories(v));
                  },
                  hintText: S.of(context).searchCategory,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
