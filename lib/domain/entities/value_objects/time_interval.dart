class TimeInterval {
  final DateTime _createdAt;
  final DateTime _updatedAt;

  TimeInterval({required DateTime createdAt, required DateTime updatedAt})
    : _createdAt = createdAt,
      _updatedAt = updatedAt;

  DateTime get updatedAt => _updatedAt;

  DateTime get createdAt => _createdAt;
}
