import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import '../../history/history.dart';
import '../bloc/incomes_bloc.dart';
import '../bloc/incomes_state.dart';
import '../bloc/incomes_event.dart';

@RoutePage()
class IncomesScreen extends StatefulWidget {
  const IncomesScreen({super.key});

  @override
  State<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncomesBloc(
        transactionRepository: context.read<TransactionRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )..add(LoadIncomes()),
      child: BlocConsumer<IncomesBloc, IncomesState>(
        listener: (context, state) {
          if (state is IncomesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is IncomesInitial || state is IncomesLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is IncomesError) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: Center(child: Text('Ошибка: ${state.message}')),
            );
          } else if (state is IncomesLoaded || state is IncomesRefreshing) {
            return _buildContent(context, state);
          }
          return const Scaffold(
            body: Center(child: Text('Неизвестное состояние')),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.green,
      elevation: 0,
      title: const Text(
        'Доходы сегодня',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(isIncome: true),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, IncomesState state) {
    final incomes = state is IncomesLoaded
        ? state.incomes
        : (state as IncomesRefreshing).incomes;
    final total = state is IncomesLoaded
        ? state.total
        : (state as IncomesRefreshing).total;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD9F3DB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Всего',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${formatCurrency(total)} ₽',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: incomes.isEmpty
                ? const Center(child: Text('Нет доходов за сегодня'))
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<IncomesBloc>().add(RefreshIncomes());
                    },
                    child: BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, catState) {
                        List<CategoryDTO> categories = [];
                        if (catState is CategoriesLoaded) {
                          categories = catState.categories;
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: incomes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final transaction = incomes[index];
                            final cat = categories.firstWhere(
                              (c) => c.id == transaction.categoryId,
                              orElse: () => CategoryDTO(
                                id: 0,
                                name: 'Доход',
                                emoji: '💰',
                                isIncome: true,
                                color: '#E0E0E0',
                              ),
                            );
                            return MyItemListTile(
                              transaction: transaction,
                              category: cat,
                              bgColor: Color(
                                int.parse(cat.color.replaceFirst('#', '0xff')),
                              ),
                              onTap: () =>
                                  _editTransaction(context, transaction, cat),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'income_fab',
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionAddScreen(isIncome: true),
            ),
          );
          context.read<IncomesBloc>().add(RefreshIncomes());
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    Transaction transaction,
    CategoryDTO category,
  ) async {
    final transactionModel = TransactionDomainMapper.domainToModel(
      transaction,
      category,
      'Сбербанк', // TODO: получить реальное название аккаунта
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditScreen(transaction: transactionModel),
      ),
    );

    // Обновляем список после возврата с экрана редактирования
    context.read<IncomesBloc>().add(RefreshIncomes());
  }
}
