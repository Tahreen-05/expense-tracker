part of 'get_categories_bloc.dart';

sealed class GetCategoriesEvent extends Equatable {
  const GetCategoriesEvent();

  @override
  List<Object> get props => [];
}

class GetCategories extends GetCategoriesEvent {}

class DeleteCategory extends GetCategoriesEvent {
  final String categoryId;
  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}