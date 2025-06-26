import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'expense_repo.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');
	final expenseCollection = FirebaseFirestore.instance.collection('expenses');

=======

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4

  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
<<<<<<< HEAD
        .doc(category.categoryId)
        .set(category.toEntity().toDocument());
=======
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
<<<<<<< HEAD
      return await categoryCollection
        .get()
        .then((value) => value.docs.map((e) => 
          Category.fromEntity(CategoryEntity.fromDocument(e.data()))
        ).toList());
=======
      return await categoryCollection.get().then((value) => value.docs
          .map(
              (e) => Category.fromEntity(CategoryEntity.fromDocument(e.data())))
          .toList());
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
<<<<<<< HEAD
        .doc(expense.expenseId)
        .set(expense.toEntity().toDocument());
=======
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
<<<<<<< HEAD
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      return await expenseCollection
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((value) => value.docs.map((e) => 
          Expense.fromEntity(ExpenseEntity.fromDocument(e.data()))
        ).toList());
=======
      return await expenseCollection.get().then((value) => value.docs
          .map((e) => Expense.fromEntity(ExpenseEntity.fromDocument(e.data())))
          .toList());
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
<<<<<<< HEAD

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoryCollection.doc(categoryId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await expenseCollection.doc(expenseId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

}
=======
}
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
