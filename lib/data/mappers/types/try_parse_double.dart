import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/parsing_failure.dart';

// Returns double or Failure if parsing fails
Either<Failure, double> tryParseDouble(String source, String fieldName) {
  final value = double.tryParse(source);
  return value != null
      ? right(value)
      : left(ParsingFailure('Поле $fieldName должно быть числом'));
}
