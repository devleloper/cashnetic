// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(txCount) => "Транзакции: ${txCount}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О приложении"),
    "account": MessageLookupByLibrary.simpleMessage("Счёт"),
    "accountName": MessageLookupByLibrary.simpleMessage("Название счёта"),
    "addExpense": MessageLookupByLibrary.simpleMessage("Добавить расход"),
    "addIncome": MessageLookupByLibrary.simpleMessage("Добавить доход"),
    "amount": MessageLookupByLibrary.simpleMessage("Сумма"),
    "amountMustBeAPositiveNumber": MessageLookupByLibrary.simpleMessage(
      "Сумма должна быть положительным числом",
    ),
    "april": MessageLookupByLibrary.simpleMessage("Апрель"),
    "august": MessageLookupByLibrary.simpleMessage("Август"),
    "balance": MessageLookupByLibrary.simpleMessage("Баланс"),
    "byAmountAsc": MessageLookupByLibrary.simpleMessage(
      "По сумме (возрастание)",
    ),
    "byAmountDesc": MessageLookupByLibrary.simpleMessage("По сумме (убывание)"),
    "byDateNewestFirst": MessageLookupByLibrary.simpleMessage(
      "По дате (сначала новые)",
    ),
    "byDateOldestFirst": MessageLookupByLibrary.simpleMessage(
      "По дате (сначала старые)",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "categories": MessageLookupByLibrary.simpleMessage("Категории"),
    "category": MessageLookupByLibrary.simpleMessage("Категория"),
    "categoryName": MessageLookupByLibrary.simpleMessage("Название категории"),
    "changePasscode": MessageLookupByLibrary.simpleMessage(
      "Изменить пароль‑код",
    ),
    "comment": MessageLookupByLibrary.simpleMessage("Комментарий"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Создать счёт"),
    "createCategory": MessageLookupByLibrary.simpleMessage("Создать категорию"),
    "currency": MessageLookupByLibrary.simpleMessage("Валюта"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Тёмная тема"),
    "date": MessageLookupByLibrary.simpleMessage("Дата"),
    "december": MessageLookupByLibrary.simpleMessage("Декабрь"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Удалить счёт?"),
    "developerDevletBoltaevnversion100nnthankYouForUsingCashnetic":
        MessageLookupByLibrary.simpleMessage(
          "Разработчик: Devlet Boltaev. Версия: 1.0.0. Спасибо за использование Cashnetic!",
        ),
    "digits": MessageLookupByLibrary.simpleMessage("4–6 цифр"),
    "dollar": MessageLookupByLibrary.simpleMessage("\\\$ Доллар"),
    "editAccounts": MessageLookupByLibrary.simpleMessage("Редактировать счета"),
    "emoji": MessageLookupByLibrary.simpleMessage("Эмодзи"),
    "english": MessageLookupByLibrary.simpleMessage("Английский"),
    "enter": MessageLookupByLibrary.simpleMessage("Ввести"),
    "enterANumber": MessageLookupByLibrary.simpleMessage("Введите число"),
    "enterAmount": MessageLookupByLibrary.simpleMessage("Введите сумму"),
    "enterName": MessageLookupByLibrary.simpleMessage("Введите название"),
    "enterPasscode": MessageLookupByLibrary.simpleMessage("Введите пароль‑код"),
    "euro": MessageLookupByLibrary.simpleMessage("€ Евро"),
    "expense": MessageLookupByLibrary.simpleMessage("Расход"),
    "expenseAnalysis": MessageLookupByLibrary.simpleMessage("Анализ расходов"),
    "expenses": MessageLookupByLibrary.simpleMessage("Расходы"),
    "expensesForTheMonth": MessageLookupByLibrary.simpleMessage(
      "Расходы за месяц",
    ),
    "expensesToday": MessageLookupByLibrary.simpleMessage("Расходы за сегодня"),
    "february": MessageLookupByLibrary.simpleMessage("Февраль"),
    "formInitializationError": MessageLookupByLibrary.simpleMessage(
      "Ошибка инициализации формы",
    ),
    "haptics": MessageLookupByLibrary.simpleMessage("Вибрация"),
    "income": MessageLookupByLibrary.simpleMessage("Доход"),
    "incomeAnalysis": MessageLookupByLibrary.simpleMessage("Анализ доходов"),
    "incomeForTheMonth": MessageLookupByLibrary.simpleMessage("Доход за месяц"),
    "incomeToday": MessageLookupByLibrary.simpleMessage("Доход за сегодня"),
    "january": MessageLookupByLibrary.simpleMessage("Январь"),
    "july": MessageLookupByLibrary.simpleMessage("Июль"),
    "june": MessageLookupByLibrary.simpleMessage("Июнь"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "mainAccount": MessageLookupByLibrary.simpleMessage("Основной счёт"),
    "march": MessageLookupByLibrary.simpleMessage("Март"),
    "may": MessageLookupByLibrary.simpleMessage("Май"),
    "moveAllTransactionsToAnotherAccount": MessageLookupByLibrary.simpleMessage(
      "Перенести все транзакции на другой счёт?",
    ),
    "moveToAnotherAccount": MessageLookupByLibrary.simpleMessage(
      "Перенести на другой счёт",
    ),
    "myAccounts": MessageLookupByLibrary.simpleMessage("Мои счета"),
    "noAccounts": MessageLookupByLibrary.simpleMessage("Нет счетов"),
    "noCategories": MessageLookupByLibrary.simpleMessage("Нет категорий"),
    "noCategoriesFoundForYourQuery": MessageLookupByLibrary.simpleMessage(
      "Категории по запросу не найдены",
    ),
    "noDataForAnalysis": MessageLookupByLibrary.simpleMessage(
      "Нет данных для анализа",
    ),
    "noDataForChart": MessageLookupByLibrary.simpleMessage(
      "Нет данных для графика",
    ),
    "noExpensesForTheLastMonth": MessageLookupByLibrary.simpleMessage(
      "Нет расходов за прошлый месяц",
    ),
    "noExpensesForToday": MessageLookupByLibrary.simpleMessage(
      "Нет расходов за сегодня",
    ),
    "noIncomeForTheLastMonth": MessageLookupByLibrary.simpleMessage(
      "Нет доходов за прошлый месяц",
    ),
    "noIncomeForToday": MessageLookupByLibrary.simpleMessage(
      "Нет доходов за сегодня",
    ),
    "notSet": MessageLookupByLibrary.simpleMessage("Не задано"),
    "november": MessageLookupByLibrary.simpleMessage("Ноябрь"),
    "october": MessageLookupByLibrary.simpleMessage("Октябрь"),
    "onlyANumber": MessageLookupByLibrary.simpleMessage(
      "Допустимо только число",
    ),
    "passcode": MessageLookupByLibrary.simpleMessage("Пароль‑код"),
    "periodEnd": MessageLookupByLibrary.simpleMessage("Период: конец"),
    "periodStart": MessageLookupByLibrary.simpleMessage("Период: начало"),
    "primaryColor": MessageLookupByLibrary.simpleMessage("Основной цвет"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "russian": MessageLookupByLibrary.simpleMessage("Русский"),
    "russianRuble": MessageLookupByLibrary.simpleMessage("₽ Российский рубль"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "searchCategory": MessageLookupByLibrary.simpleMessage("Поиск категории"),
    "selectAccount": MessageLookupByLibrary.simpleMessage("Выберите счёт"),
    "selectAccountToTransfer": MessageLookupByLibrary.simpleMessage(
      "Выберите счёт для перевода",
    ),
    "selectCategory": MessageLookupByLibrary.simpleMessage(
      "Выберите категорию",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "september": MessageLookupByLibrary.simpleMessage("Сентябрь"),
    "set": MessageLookupByLibrary.simpleMessage("Установить"),
    "setPasscode": MessageLookupByLibrary.simpleMessage(
      "Установить пароль‑код",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "sounds": MessageLookupByLibrary.simpleMessage("Звуки"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "total": MessageLookupByLibrary.simpleMessage("Итого"),
    "transactionsTxcount": m0,
    "unknownState": MessageLookupByLibrary.simpleMessage(
      "Неизвестное состояние",
    ),
    "validationErrors": MessageLookupByLibrary.simpleMessage(
      "Ошибка валидации:",
    ),
  };
}
