import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'get_expenses_event.dart';
part 'get_expenses_state.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  ExpenseRepository expenseRepository;

  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpenses>((event, emit) async {
      emit(GetExpensesLoading());
      try {
        List<Expense> expenses = await expenseRepository.getExpenses();
        emit(GetExpensesSuccess(expenses));
      } catch (e) {
        emit(GetExpensesFailure());
      }
    });

    on<DeleteExpense>((event, emit) async {
      try {
        await expenseRepository.deleteExpense(event.expenseId);
        add(GetExpenses()); // Refresh after delete
      } catch (e) {
        emit(GetExpensesFailure());
      }
    });
  }
}
