import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';

class Transaction {
  final int id;
  final int accountId;
  final int? categoryId;
  final double amount;
  final DateTime timestamp;
  final String? comment;
  final TimeInterval timeInterval;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.timestamp,
    required this.comment,
    required this.timeInterval,
  });
}
