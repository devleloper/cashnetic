import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/data/database.dart' as db;

extension CategoryMapper on CategoryDTO {
  Either<Failure, domain.Category> toDomain() {
    return right(
      domain.Category(
        id: this.id,
        name: name,
        emoji: emoji,
        isIncome: isIncome,
        color: color,
      ),
    );
  }
}

extension DbCategoryMapper on db.Category {
  domain.Category toDomain() {
    return domain.Category(
      id: this.id,
      name: this.name,
      emoji: this.emoji,
      isIncome: this.isIncome,
      color: this.color,
    );
  }
}
