import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/data/api_client.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';

class MockAppDatabase extends Mock implements db.AppDatabase {}
class MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(db.TransactionsCompanion());
    registerFallbackValue(db.PendingEventsCompanion());
  });
  late MockAppDatabase mockDb;
  late MockApiClient mockApiClient;
  late DriftTransactionRepository repository;

  setUp(() {
    mockDb = MockAppDatabase();
    mockApiClient = MockApiClient();
    repository = DriftTransactionRepository(mockDb, mockApiClient);
  });

  group('DriftTransactionRepository', () {
    test('createTransaction returns Right(domain.Transaction) on success', () async {
      // Arrange
      final form = TransactionForm(
        accountId: 1,
        categoryId: 2,
        amount: 100.0,
        timestamp: DateTime(2024, 7, 1, 12, 0),
        comment: 'Test transaction',
      );
      const insertedId = 42;
      final dbTransaction = db.Transaction(
        id: insertedId,
        clientId: 'uuid',
        accountId: 1,
        categoryId: 2,
        amount: 100.0,
        timestamp: DateTime(2024, 7, 1, 12, 0),
        comment: 'Test transaction',
        createdAt: DateTime(2024, 7, 1, 12, 0),
        updatedAt: DateTime(2024, 7, 1, 12, 0),
      );

      when(() => mockDb.insertTransaction(any())).thenAnswer((_) async => insertedId);

      when(() => mockDb.insertPendingEvent(any())).thenAnswer((_) async => 1);
 
      when(() => mockDb.getTransactionById(insertedId)).thenAnswer((_) async => dbTransaction);

      // Act
      final result = await repository.createTransaction(form);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (tx) {
          expect(tx.accountId, 1);
          expect(tx.categoryId, 2);
          expect(tx.amount, 100.0);
          expect(tx.comment, 'Test transaction');
        },
      );
      verify(() => mockDb.insertTransaction(any())).called(1);
      verify(() => mockDb.insertPendingEvent(any())).called(1);
      verify(() => mockDb.getTransactionById(insertedId)).called(1);
    });

    test('getTransactionById returns Right(domain.Transaction) when found', () async {
      // Arrange
      const txId = 123;
      final dbTransaction = db.Transaction(
        id: txId,
        clientId: 'uuid',
        accountId: 1,
        categoryId: 2,
        amount: 50.0,
        timestamp: DateTime(2024, 7, 2, 10, 0),
        comment: 'Found transaction',
        createdAt: DateTime(2024, 7, 2, 10, 0),
        updatedAt: DateTime(2024, 7, 2, 10, 0),
      );
      when(() => mockDb.getTransactionById(txId)).thenAnswer((_) async => dbTransaction);

      // Act
      final result = await repository.getTransactionById(txId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (tx) {
          expect(tx.id, txId);
          expect(tx.amount, 50.0);
          expect(tx.comment, 'Found transaction');
        },
      );
      verify(() => mockDb.getTransactionById(txId)).called(1);
    });

    test('getTransactionById returns Left(RepositoryFailure) when not found', () async {
      // Arrange
      const txId = 999;
      when(() => mockDb.getTransactionById(txId)).thenAnswer((_) async => null);

      // Act
      final result = await repository.getTransactionById(txId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<RepositoryFailure>());
          expect((failure as RepositoryFailure).message, contains('not found'));
        },
        (_) => fail('Should be Left'),
      );
      verify(() => mockDb.getTransactionById(txId)).called(1);
    });
  });
} 