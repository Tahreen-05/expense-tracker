import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {

  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory();

  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpenses();
<<<<<<< HEAD

  Future<void> deleteCategory(String categoryId);

  Future<void> deleteExpense(String expenseId);
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
}