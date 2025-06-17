import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';

class Transaction {
  final int _id;
  final int _accountId;
  final int? _categoryId;
  final double _amount;
  final DateTime _timestamp;
  final String? _comment;
  final TimeInterval _timeInterval;

  Transaction({
    required int id,
    required int accountId,
    required int? categoryId,
    required double amount,
    required DateTime timestamp,
    required String? comment,
    required TimeInterval timeInterval,
  }) : _id = id,
       _accountId = accountId,
       _categoryId = categoryId,
       _amount = amount,
       _timestamp = timestamp,
       _comment = comment,
       _timeInterval = timeInterval;

  TimeInterval get timeInterval => _timeInterval;

  String? get comment => _comment;

  DateTime get timestamp => _timestamp;

  double get amount => _amount;

  int? get categoryId => _categoryId;

  int get accountId => _accountId;

  int get id => _id;
}
