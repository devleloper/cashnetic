import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/parsing_failure.dart';

Either<Failure, List<T>> tryParseNestedList<T>(
  Iterable<Either<Failure, T>> list,
) {
  // Collects all successful Right values, but if any Left — returns it.
  final result = <T>[];
  for (final either in list) {
    if (either.isLeft()) {
      return left(
        either.swap().getOrElse(() => ParsingFailure('Unknown error')),
      );
    }
    result.add(either.getOrElse(() => throw StateError('Unreachable')));
  }
  return right(result);
}
