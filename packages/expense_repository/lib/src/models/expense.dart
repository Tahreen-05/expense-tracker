import 'package:expense_repository/expense_repository.dart';

class Expense {
  String expenseId;
  Category category;
  DateTime date;
  int amount;
<<<<<<< HEAD
  String userId;
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4

  Expense({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
<<<<<<< HEAD
    required this.userId,
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
  });

  static final empty = Expense(
    expenseId: '',
    category: Category.empty,
    date: DateTime.now(),
    amount: 0,
<<<<<<< HEAD
    userId: '',
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
  );

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      category: category,
      date: date,
      amount: amount,
<<<<<<< HEAD
      userId: userId,
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    );
  }

  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      expenseId: entity.expenseId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount,
<<<<<<< HEAD
      userId: entity.userId,
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    );
  }
}
