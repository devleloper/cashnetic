import 'failure.dart';

class RepositoryFailure extends Failure {
  const RepositoryFailure(String message)
    : super('Ошибка при работе с репозиторием: "$message"');
}
