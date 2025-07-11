import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// Database singleton
final appDatabaseSingleton = AppDatabase();

// Accounts table
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientId => text().nullable()(); // UUID for offline-first
  TextColumn get name => text()();
  TextColumn get currency => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Categories table
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('💰'))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get color => text().withDefault(const Constant('#E0E0E0'))();
}

// Transactions table
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientId => text().nullable()(); // UUID for offline-first
  IntColumn get accountId =>
      integer().customConstraint('REFERENCES accounts(id) NOT NULL')();
  IntColumn get categoryId =>
      integer().nullable().customConstraint('REFERENCES categories(id)')();
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get comment => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Event sourcing table
class PendingEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()(); // account, category, transaction
  TextColumn get type => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, syncing, synced, failed
}

// Sync state table for revision/timestamp tracking
class SyncState extends Table {
  TextColumn get entity => text()(); // account, category, transaction
  TextColumn get lastRevision =>
      text().nullable()(); // revision or timestamp as string
  @override
  Set<Column> get primaryKey => {entity};
}

@DriftDatabase(
  tables: [Accounts, Categories, Transactions, PendingEvents, SyncState],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Accounts DAO
  Future<int> insertAccount(AccountsCompanion entry) =>
      into(accounts).insert(entry);
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Future<Account?> getAccountById(int id) =>
      (select(accounts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<bool> updateAccount(Account entry) => update(accounts).replace(entry);
  Future<int> deleteAccount(int id) =>
      (delete(accounts)..where((tbl) => tbl.id.equals(id))).go();

  // Categories DAO
  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  // Transactions DAO
  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();
  Future<Transaction?> getTransactionById(int id) => (select(
    transactions,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);
  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();

  // Insert or replace (upsert) for transaction
  Future<int> insertOrReplaceTransaction(Transaction entry) =>
      into(transactions).insertOnConflictUpdate(entry);

  // PendingEvents DAO
  Future<int> insertPendingEvent(PendingEventsCompanion entry) =>
      into(pendingEvents).insert(entry);
  Future<List<PendingEvent>> getAllPendingEvents() =>
      select(pendingEvents).get();
  Future<void> deletePendingEvent(int id) =>
      (delete(pendingEvents)..where((tbl) => tbl.id.equals(id))).go();
  Future<void> updatePendingEventStatus(int id, String status) async {
    await (update(pendingEvents)..where((tbl) => tbl.id.equals(id))).write(
      PendingEventsCompanion(status: Value(status)),
    );
  }

  // SyncState DAO
  Future<String?> getLastRevision(String entity) async {
    final row = await (select(
      syncState,
    )..where((tbl) => tbl.entity.equals(entity))).getSingleOrNull();
    return row?.lastRevision;
  }

  Future<void> setLastRevision(String entity, String revision) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateCompanion(entity: Value(entity), lastRevision: Value(revision)),
    );
  }

  // Batch replace accounts (delete all and insert new)
  Future<void> replaceAllAccounts(List<Account> newAccounts) async {
    await batch((batch) {
      batch.deleteWhere(accounts, (_) => const Constant(true));
      batch.insertAll(accounts, newAccounts);
    });
  }

  // Batch replace categories
  Future<void> replaceAllCategories(List<Category> newCategories) async {
    await batch((batch) {
      batch.deleteWhere(categories, (_) => const Constant(true));
      batch.insertAll(categories, newCategories);
    });
  }

  // Batch replace transactions
  Future<void> replaceAllTransactions(List<Transaction> newTransactions) async {
    await batch((batch) {
      batch.deleteWhere(transactions, (_) => const Constant(true));
      batch.insertAll(transactions, newTransactions);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cashnetic.sqlite'));
    return NativeDatabase(file);
  });
}
