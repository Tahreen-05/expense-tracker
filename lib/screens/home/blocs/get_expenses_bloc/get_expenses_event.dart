part of 'get_expenses_bloc.dart';

sealed class GetExpensesEvent extends Equatable {
  const GetExpensesEvent();

  @override
  List<Object> get props => [];
}

<<<<<<< HEAD
class GetExpenses extends GetExpensesEvent{}

class DeleteExpense extends GetExpensesEvent {
  final String expenseId;
  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}
=======
class GetExpenses extends GetExpensesEvent{}
>>>>>>> ba32001186576face6cfda194fecdbb571f903c4
