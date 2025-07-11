import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoriesEvent {}

class SearchCategories extends CategoriesEvent {
  final String query;
  const SearchCategories(this.query);
  @override
  List<Object?> get props => [query];
}

class AddCategory extends CategoriesEvent {
  final dynamic category; // clarify type after domain/data integration
  const AddCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoriesEvent {
  final int categoryId;
  const DeleteCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class LoadTransactionsForCategory extends CategoriesEvent {
  final int categoryId;
  const LoadTransactionsForCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class InitCategoriesWithTransactions extends CategoriesEvent {}
