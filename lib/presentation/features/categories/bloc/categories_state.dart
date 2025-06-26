import 'package:equatable/equatable.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();
  @override
  List<Object?> get props => [];
}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryDTO> categories;
  final List<CategoryDTO> allCategories;
  final String searchQuery;
  final Map<int, List<Transaction>> txByCategory;
  const CategoriesLoaded({
    required this.categories,
    required this.allCategories,
    this.searchQuery = '',
    this.txByCategory = const {},
  });
  @override
  List<Object?> get props => [categories, searchQuery, txByCategory];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
  @override
  List<Object?> get props => [message];
}
