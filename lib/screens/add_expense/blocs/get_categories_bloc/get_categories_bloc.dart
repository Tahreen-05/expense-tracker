import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  final ExpenseRepository expenseRepository;

  GetCategoriesBloc(this.expenseRepository) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('categories')
            .where('userId', isEqualTo: uid)
            .get();

        if (snapshot.docs.isEmpty) {
          emit(const GetCategoriesSuccess([])); // send empty list
          return;
        }

        final categories = snapshot.docs.map((doc) {
          final data = doc.data();
          return Category(
            categoryId: doc.id,
            name: data['name'],
            icon: data['icon'],
            color: data['color'],
            totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
          );
        }).toList();

        emit(GetCategoriesSuccess(categories));
      } catch (e) {
        emit(GetCategoriesFailure());
      }
    });
    on<DeleteCategory>((event, emit) async {
      try {
        await expenseRepository.deleteCategory(event.categoryId);
        add(GetCategories()); // Refresh after delete
      } catch (e) {
        emit(GetCategoriesFailure());
      }
    });
  }
}
