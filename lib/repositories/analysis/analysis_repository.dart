import '../../models/transactions/transaction_model.dart';
import '../transactions/transactions_repository.dart';

abstract class AnalysisRepository {
  Future<List<TransactionModel>> fetchTransactions({
    required DateTime from,
    required DateTime to,
  });
}

class AnalysisRepositoryImpl implements AnalysisRepository {
  final TransactionsRepository transactionsRepo;

  AnalysisRepositoryImpl({required this.transactionsRepo});

  @override
  Future<List<TransactionModel>> fetchTransactions({
    required DateTime from,
    required DateTime to,
  }) async {
    final all = await transactionsRepo.loadTransactions();
    return all.where((t) {
      final dt = DateTime.fromMillisecondsSinceEpoch(t.id);
      return dt.isAtSameMomentAs(from) ||
          dt.isAtSameMomentAs(to) ||
          (dt.isAfter(from) && dt.isBefore(to));
    }).toList();
  }
}
