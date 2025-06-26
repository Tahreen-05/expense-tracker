import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/entities.dart';

import '../models/models.dart';

class ExpenseEntity {
  String expenseId;
  Category category;
  DateTime date;
  int amount;
<<<<<<< HEAD
  String userId;
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
<<<<<<< HEAD
    required this.userId,
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
  });

  Map<String, Object?> toDocument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDocument(),
      'date': date,
      'amount': amount,
<<<<<<< HEAD
      'userId': userId,
=======
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
    };
  }

  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      expenseId: doc['expenseId'],
<<<<<<< HEAD
      category: Category.fromEntity(CategoryEntity.fromDocument(doc['category'])),
      date: (doc['date'] as Timestamp).toDate(),
      amount: doc['amount'],
      userId: doc['userId'],
    );
  }
}
=======
      category:
          Category.fromEntity(CategoryEntity.fromDocument(doc['category'])),
      date: (doc['date'] as Timestamp).toDate(),
      amount: doc['amount'],
    );
  }
}
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
