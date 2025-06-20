import 'failure.dart';

class ParsingFailure extends Failure {
  const ParsingFailure(String requirement)
    : super('Ошибка при парсинге данных: "$requirement"');
}
