import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';

extension CategoryMapper on CategoryDTO {
  Either<Failure, Category> toDomain() {
    return right(
      Category(id: this.id, name: name, emoji: emoji, isIncome: isIncome),
    );
  }
}
