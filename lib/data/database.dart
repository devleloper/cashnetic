import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

// Синглтон базы данных
final appDatabaseSingleton = AppDatabase();

// Таблица счетов
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get currency => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Таблица категорий
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('💰'))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get color => text().withDefault(const Constant('#E0E0E0'))();
}

// Таблица транзакций
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId =>
      integer().customConstraint('REFERENCES accounts(id)')();
  IntColumn get categoryId =>
      integer().nullable().customConstraint('REFERENCES categories(id)')();
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get comment => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Таблица поисковых запросов для категорий
class SearchQueries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, SearchQueries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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

  // SearchQueries DAO
  Future<void> saveSearchQuery(String query) async {
    // Очищаем старое значение (у нас всегда только 1)
    await delete(this.searchQueries).go();
    await into(
      this.searchQueries,
    ).insert(SearchQueriesCompanion(query: Value(query)));
  }

  Future<String?> getLastSearchQuery() async {
    final res = await select(this.searchQueries).getSingleOrNull();
    return res?.query;
  }

  Future<void> deleteSearchQuery() async {
    await delete(this.searchQueries).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cashnetic.sqlite'));
    return NativeDatabase(file);
  });
}
