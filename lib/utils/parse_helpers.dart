import 'package:dartz/dartz.dart';
import '../domain/failures/failure.dart';
import '../domain/failures/parsing_failure.dart';

Either<Failure, double> tryParseDouble(String input, String field) {
  final v = double.tryParse(input);
  return v != null
      ? Right(v)
      : Left(ParsingFailure('Field $field must be numeric'));
}

Either<Failure, DateTime> tryParseDateTime(String input, String field) {
  final dt = DateTime.tryParse(input);
  return dt != null
      ? Right(dt)
      : Left(ParsingFailure('Field $field invalid datetime'));
}
