import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/history/view/history_screen.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';
import '../widgets/transactions_total_row.dart';
import '../widgets/transactions_list_view.dart';

@RoutePage()
class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final GlobalKey historyIconKey = GlobalKey();
  TransactionsScreen({Key? key, required this.isIncome}) : super(key: key);

  void _animateTransactionToHistory(
    BuildContext context,
    TransactionDTO tx,
  ) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Получаем RenderBox и позиции
    final fabBox = context.findRenderObject() as RenderBox?;
    final fabOffset =
        fabBox?.localToGlobal(fabBox.size.center(Offset.zero)) ?? Offset.zero;

    final historyBox =
        historyIconKey.currentContext?.findRenderObject() as RenderBox?;
    Offset historyOffset = Offset.zero;
    if (historyBox != null) {
      final position = historyBox.localToGlobal(Offset.zero);
      final size = historyBox.size;
      // Адаптивное смещение: 20% ширины иконки вправо от центра
      final double relativeOffsetX = size.width * 2.7;
      historyOffset =
          position + Offset(size.width / 2 + relativeOffsetX, size.height / 2);
    }

    // Если не удалось получить позиции — не анимируем
    if (fabOffset == Offset.zero || historyOffset == Offset.zero) return;

    // Получаем emoji категории заранее, пока context видит Bloc
    final emoji = _getCategoryEmoji(context, tx.categoryId);

    final entry = OverlayEntry(
      builder: (context) {
        return _TransactionFlyCircle(
          start: fabOffset,
          end: historyOffset,
          emoji: emoji,
          amount: tx.amount,
        );
      },
    );
    overlay.insert(entry);
    // Длительность анимации: 900 мс перемещение + 500 мс пауза на иконке + 300 мс fade-out
    await Future.delayed(const Duration(milliseconds: 1700));
    entry.remove();
  }

  String _getCategoryEmoji(BuildContext context, int categoryId) {
    final state = BlocProvider.of<TransactionsBloc>(context).state;
    if (state is TransactionsLoaded) {
      if (state.categories.isEmpty) return '❓';
      final first = state.categories.first;
      if (first is CategoryDTO) {
        final cat = (state.categories as List<CategoryDTO>).firstWhere(
          (c) => c.id == categoryId,
          orElse: () => CategoryDTO(
            id: 0,
            name: '',
            emoji: '❓',
            isIncome: isIncome,
            color: '#FFF',
          ),
        );
        return cat.emoji;
      } else if (first is Category) {
        final cat = (state.categories as List<Category>).firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(
            id: 0,
            name: '',
            emoji: '❓',
            isIncome: isIncome,
            color: '#FFF',
          ),
        );
        return cat.emoji;
      }
    }
    return '❓';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionsBloc(
        transactionRepository: context.read<TransactionRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )..add(TransactionsLoad(isIncome: isIncome)),
      child: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is TransactionsError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          if (state is! TransactionsLoaded) {
            return const SizedBox.shrink();
          }
          final transactions = state.transactions;
          final categories = state.categories;
          final total = state.total;
          return Scaffold(
            appBar: AppBar(
              title: Text(isIncome ? 'Доходы сегодня' : 'Расходы сегодня'),
              actions: [
                IconButton(
                  key: historyIconKey,
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(isIncome: isIncome),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                TransactionsTotalRow(total: total),

                const SizedBox(height: 8),
                Expanded(
                  child: TransactionsListView(
                    transactions: transactions,
                    categories: categories,
                    isIncome: isIncome,
                    onTap: (t, cat) async {
                      final model = TransactionDomainMapper.domainToModel(
                        t,
                        CategoryDTO(
                          id: cat.id,
                          name: cat.name,
                          emoji: cat.emoji,
                          isIncome: cat.isIncome,
                          color: cat.color,
                        ),
                        'Сбербанк',
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionEditScreen(transaction: model),
                        ),
                      );
                      context.read<TransactionsBloc>().add(
                        TransactionsLoad(isIncome: isIncome),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: isIncome ? 'income_fab' : 'expense_fab',
              backgroundColor: Colors.green,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionAddScreen(isIncome: isIncome),
                  ),
                );
                context.read<TransactionsBloc>().add(
                  TransactionsLoad(isIncome: isIncome),
                );
                if (result != null &&
                    result is Map &&
                    result['animateToHistory'] == true) {
                  _animateTransactionToHistory(
                    context,
                    result['transaction'] as TransactionDTO,
                  );
                }
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionFlyCircle extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String emoji;
  final String amount;
  const _TransactionFlyCircle({
    required this.start,
    required this.end,
    required this.emoji,
    required this.amount,
  });

  @override
  State<_TransactionFlyCircle> createState() => _TransactionFlyCircleState();
}

class _TransactionFlyCircleState extends State<_TransactionFlyCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ), // 900 мс движение + 300 мс fade
    );
    _positionAnim = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOutCubic),
      ),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );
    _opacityAnim = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 75,
      ), // 0-900 мс — opacity 1
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 25,
      ), // 900-1200 fade-out
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pos = _positionAnim.value;
        return Positioned(
          left: pos.dx - 28,
          top: pos.dy - 28,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 2),
                    Text(
                      widget.amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
