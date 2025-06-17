import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/enums/change_type.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/parsing_failure.dart';

Either<Failure, ChangeType> tryParseChangeType(
  String source,
  String fieldName,
) {
  try {
    return right(ChangeType.values.byName(source));
  } catch (_) {
    return left(
      ParsingFailure('Неизвестный ChangeType: "$source" в поле $fieldName'),
    );
  }
}
