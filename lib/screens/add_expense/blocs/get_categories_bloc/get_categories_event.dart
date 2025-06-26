part of 'get_categories_bloc.dart';

sealed class GetCategoriesEvent extends Equatable {
  const GetCategoriesEvent();

  @override
  List<Object> get props => [];
}

<<<<<<< HEAD
class GetCategories extends GetCategoriesEvent {}

class DeleteCategory extends GetCategoriesEvent {
  final String categoryId;
  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
=======
class GetCategories extends GetCategoriesEvent {}
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
