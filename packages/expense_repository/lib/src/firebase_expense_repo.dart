import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'expense_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');
	final expenseCollection = FirebaseFirestore.instance.collection('expenses');


  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
        .doc(category.categoryId)
        .set(category.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
      return await categoryCollection
        .get()
        .then((value) => value.docs.map((e) => 
          Category.fromEntity(CategoryEntity.fromDocument(e.data()))
        ).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
        .doc(expense.expenseId)
        .set(expense.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      return await expenseCollection
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((value) => value.docs.map((e) => 
          Expense.fromEntity(ExpenseEntity.fromDocument(e.data()))
        ).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

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