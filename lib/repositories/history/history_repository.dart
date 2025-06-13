import '../../models/transactions/transaction_model.dart';
import '../transactions/transactions_repository.dart';

abstract class HistoryRepository {
  Future<List<TransactionModel>> loadAllTransactions();
}

class HistoryRepositoryImpl implements HistoryRepository {
  final TransactionsRepository txRepo;

  HistoryRepositoryImpl({required this.txRepo});

  @override
  Future<List<TransactionModel>> loadAllTransactions() async {
    return txRepo.loadTransactions();
  }
}
