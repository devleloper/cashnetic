import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/forms/category_form.dart';

extension CategoryMapper on CategoryDTO {
  Either<Failure, domain.Category> toDomain() {
    return right(
      domain.Category(
        id: this.id,
        name: name,
        emoji: emoji,
        isIncome: isIncome,
        color: color ?? '#E0E0E0',
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

extension CategoryFormMapper on CategoryForm {
  CategoryDTO toCreateDTO() {
    return CategoryDTO(
      id: 0, // id not needed for create, but required by model
      name: name ?? '',
      emoji: emoji ?? '',
      isIncome: isIncome ?? false,
      color: color ?? '#E0E0E0',
    );
  }

  CategoryDTO toUpdateDTO(int id) {
    return CategoryDTO(
      id: id,
      name: name ?? '',
      emoji: emoji ?? '',
      isIncome: isIncome ?? false,
      color: color ?? '#E0E0E0',
    );
  }
}
