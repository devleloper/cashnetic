import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/parsing_failure.dart';

Either<Failure, double> tryParseDouble(String source, String fieldName) {
  final value = double.tryParse(source);
  return value != null
      ? right(value)
      : left(ParsingFailure('Поле $fieldName должно быть числом'));
}
