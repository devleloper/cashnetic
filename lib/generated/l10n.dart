// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `My accounts`
  String get myAccounts {
    return Intl.message('My accounts', name: 'myAccounts', desc: '', args: []);
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `₽ Russian Ruble`
  String get russianRuble {
    return Intl.message(
      '₽ Russian Ruble',
      name: 'russianRuble',
      desc: '',
      args: [],
    );
  }

  /// `\$ Dollar`
  String get dollar {
    return Intl.message('\\\$ Dollar', name: 'dollar', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `No data for chart`
  String get noDataForChart {
    return Intl.message(
      'No data for chart',
      name: 'noDataForChart',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get expense {
    return Intl.message('Expense', name: 'expense', desc: '', args: []);
  }

  /// `Income`
  String get income {
    return Intl.message('Income', name: 'income', desc: '', args: []);
  }

  /// `Create account`
  String get createAccount {
    return Intl.message(
      'Create account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Form initialization error`
  String get formInitializationError {
    return Intl.message(
      'Form initialization error',
      name: 'formInitializationError',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Enter a number`
  String get enterANumber {
    return Intl.message(
      'Enter a number',
      name: 'enterANumber',
      desc: '',
      args: [],
    );
  }

  /// `Only a number`
  String get onlyANumber {
    return Intl.message(
      'Only a number',
      name: 'onlyANumber',
      desc: '',
      args: [],
    );
  }

  /// `€ Euro`
  String get euro {
    return Intl.message('€ Euro', name: 'euro', desc: '', args: []);
  }

  /// `Account name`
  String get accountName {
    return Intl.message(
      'Account name',
      name: 'accountName',
      desc: '',
      args: [],
    );
  }

  /// `Select account to transfer`
  String get selectAccountToTransfer {
    return Intl.message(
      'Select account to transfer',
      name: 'selectAccountToTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Edit accounts`
  String get editAccounts {
    return Intl.message(
      'Edit accounts',
      name: 'editAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Delete account?`
  String get deleteAccount {
    return Intl.message(
      'Delete account?',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Move all transactions to another account?`
  String get moveAllTransactionsToAnotherAccount {
    return Intl.message(
      'Move all transactions to another account?',
      name: 'moveAllTransactionsToAnotherAccount',
      desc: '',
      args: [],
    );
  }

  /// `Move to another account`
  String get moveToAnotherAccount {
    return Intl.message(
      'Move to another account',
      name: 'moveToAnotherAccount',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message('January', name: 'january', desc: '', args: []);
  }

  /// `February`
  String get february {
    return Intl.message('February', name: 'february', desc: '', args: []);
  }

  /// `March`
  String get march {
    return Intl.message('March', name: 'march', desc: '', args: []);
  }

  /// `April`
  String get april {
    return Intl.message('April', name: 'april', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `June`
  String get june {
    return Intl.message('June', name: 'june', desc: '', args: []);
  }

  /// `July`
  String get july {
    return Intl.message('July', name: 'july', desc: '', args: []);
  }

  /// `August`
  String get august {
    return Intl.message('August', name: 'august', desc: '', args: []);
  }

  /// `September`
  String get september {
    return Intl.message('September', name: 'september', desc: '', args: []);
  }

  /// `October`
  String get october {
    return Intl.message('October', name: 'october', desc: '', args: []);
  }

  /// `November`
  String get november {
    return Intl.message('November', name: 'november', desc: '', args: []);
  }

  /// `December`
  String get december {
    return Intl.message('December', name: 'december', desc: '', args: []);
  }

  /// `Period: start`
  String get periodStart {
    return Intl.message(
      'Period: start',
      name: 'periodStart',
      desc: '',
      args: [],
    );
  }

  /// `Period: end`
  String get periodEnd {
    return Intl.message('Period: end', name: 'periodEnd', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `No data for analysis`
  String get noDataForAnalysis {
    return Intl.message(
      'No data for analysis',
      name: 'noDataForAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Expense analysis`
  String get expenseAnalysis {
    return Intl.message(
      'Expense analysis',
      name: 'expenseAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Income analysis`
  String get incomeAnalysis {
    return Intl.message(
      'Income analysis',
      name: 'incomeAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `No categories found for your query`
  String get noCategoriesFoundForYourQuery {
    return Intl.message(
      'No categories found for your query',
      name: 'noCategoriesFoundForYourQuery',
      desc: '',
      args: [],
    );
  }

  /// `Search category`
  String get searchCategory {
    return Intl.message(
      'Search category',
      name: 'searchCategory',
      desc: '',
      args: [],
    );
  }

  /// `Income for the month`
  String get incomeForTheMonth {
    return Intl.message(
      'Income for the month',
      name: 'incomeForTheMonth',
      desc: '',
      args: [],
    );
  }

  /// `Expenses for the month`
  String get expensesForTheMonth {
    return Intl.message(
      'Expenses for the month',
      name: 'expensesForTheMonth',
      desc: '',
      args: [],
    );
  }

  /// `No income for the last month`
  String get noIncomeForTheLastMonth {
    return Intl.message(
      'No income for the last month',
      name: 'noIncomeForTheLastMonth',
      desc: '',
      args: [],
    );
  }

  /// `No expenses for the last month`
  String get noExpensesForTheLastMonth {
    return Intl.message(
      'No expenses for the last month',
      name: 'noExpensesForTheLastMonth',
      desc: '',
      args: [],
    );
  }

  /// `Main account`
  String get mainAccount {
    return Intl.message(
      'Main account',
      name: 'mainAccount',
      desc: '',
      args: [],
    );
  }

  /// `By date (newest first)`
  String get byDateNewestFirst {
    return Intl.message(
      'By date (newest first)',
      name: 'byDateNewestFirst',
      desc: '',
      args: [],
    );
  }

  /// `By date (oldest first)`
  String get byDateOldestFirst {
    return Intl.message(
      'By date (oldest first)',
      name: 'byDateOldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `By amount (desc)`
  String get byAmountDesc {
    return Intl.message(
      'By amount (desc)',
      name: 'byAmountDesc',
      desc: '',
      args: [],
    );
  }

  /// `By amount (asc)`
  String get byAmountAsc {
    return Intl.message(
      'By amount (asc)',
      name: 'byAmountAsc',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expenses {
    return Intl.message('Expenses', name: 'expenses', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Developer: Devlet Boltaev. Version: 1.0.0. Thank you for using Cashnetic!`
  String get developerDevletBoltaevnversion100nnthankYouForUsingCashnetic {
    return Intl.message(
      'Developer: Devlet Boltaev. Version: 1.0.0. Thank you for using Cashnetic!',
      name: 'developerDevletBoltaevnversion100nnthankYouForUsingCashnetic',
      desc: '',
      args: [],
    );
  }

  /// `Dark theme`
  String get darkTheme {
    return Intl.message('Dark theme', name: 'darkTheme', desc: '', args: []);
  }

  /// `Primary color`
  String get primaryColor {
    return Intl.message(
      'Primary color',
      name: 'primaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Sounds`
  String get sounds {
    return Intl.message('Sounds', name: 'sounds', desc: '', args: []);
  }

  /// `Haptics`
  String get haptics {
    return Intl.message('Haptics', name: 'haptics', desc: '', args: []);
  }

  /// `Passcode`
  String get passcode {
    return Intl.message('Passcode', name: 'passcode', desc: '', args: []);
  }

  /// `Set`
  String get set {
    return Intl.message('Set', name: 'set', desc: '', args: []);
  }

  /// `Not set`
  String get notSet {
    return Intl.message('Not set', name: 'notSet', desc: '', args: []);
  }

  /// `Sync`
  String get sync {
    return Intl.message('Sync', name: 'sync', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Unknown state`
  String get unknownState {
    return Intl.message(
      'Unknown state',
      name: 'unknownState',
      desc: '',
      args: [],
    );
  }

  /// `Change passcode`
  String get changePasscode {
    return Intl.message(
      'Change passcode',
      name: 'changePasscode',
      desc: '',
      args: [],
    );
  }

  /// `Set passcode`
  String get setPasscode {
    return Intl.message(
      'Set passcode',
      name: 'setPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Enter passcode`
  String get enterPasscode {
    return Intl.message(
      'Enter passcode',
      name: 'enterPasscode',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `4-6 digits`
  String get digits {
    return Intl.message('4-6 digits', name: 'digits', desc: '', args: []);
  }

  /// `No accounts`
  String get noAccounts {
    return Intl.message('No accounts', name: 'noAccounts', desc: '', args: []);
  }

  /// `No categories`
  String get noCategories {
    return Intl.message(
      'No categories',
      name: 'noCategories',
      desc: '',
      args: [],
    );
  }

  /// `Create category`
  String get createCategory {
    return Intl.message(
      'Create category',
      name: 'createCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add income`
  String get addIncome {
    return Intl.message('Add income', name: 'addIncome', desc: '', args: []);
  }

  /// `Add expense`
  String get addExpense {
    return Intl.message('Add expense', name: 'addExpense', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Enter`
  String get enter {
    return Intl.message('Enter', name: 'enter', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Select account`
  String get selectAccount {
    return Intl.message(
      'Select account',
      name: 'selectAccount',
      desc: '',
      args: [],
    );
  }

  /// `Select category`
  String get selectCategory {
    return Intl.message(
      'Select category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter amount`
  String get enterAmount {
    return Intl.message(
      'Enter amount',
      name: 'enterAmount',
      desc: '',
      args: [],
    );
  }

  /// `Amount must be a positive number`
  String get amountMustBeAPositiveNumber {
    return Intl.message(
      'Amount must be a positive number',
      name: 'amountMustBeAPositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Transactions: {txCount}`
  String transactionsTxcount(Object txCount) {
    return Intl.message(
      'Transactions: $txCount',
      name: 'transactionsTxcount',
      desc: '',
      args: [txCount],
    );
  }

  /// `Category name`
  String get categoryName {
    return Intl.message(
      'Category name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Enter name`
  String get enterName {
    return Intl.message('Enter name', name: 'enterName', desc: '', args: []);
  }

  /// `Emoji`
  String get emoji {
    return Intl.message('Emoji', name: 'emoji', desc: '', args: []);
  }

  /// `Comment`
  String get comment {
    return Intl.message('Comment', name: 'comment', desc: '', args: []);
  }

  /// `No expenses for today`
  String get noExpensesForToday {
    return Intl.message(
      'No expenses for today',
      name: 'noExpensesForToday',
      desc: '',
      args: [],
    );
  }

  /// `No income for today`
  String get noIncomeForToday {
    return Intl.message(
      'No income for today',
      name: 'noIncomeForToday',
      desc: '',
      args: [],
    );
  }

  /// `Validation errors:`
  String get validationErrors {
    return Intl.message(
      'Validation errors:',
      name: 'validationErrors',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Income today`
  String get incomeToday {
    return Intl.message(
      'Income today',
      name: 'incomeToday',
      desc: '',
      args: [],
    );
  }

  /// `Expenses today`
  String get expensesToday {
    return Intl.message(
      'Expenses today',
      name: 'expensesToday',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
