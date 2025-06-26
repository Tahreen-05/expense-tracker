import 'package:expense_repository/expense_repository.dart';

List<Expense> getWeeklyExpenses(List<Expense> allExpenses) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
  final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

  return allExpenses.where((expense) {
    final date = expense.date;
    return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
  }).toList();
}

int getWeeklyTotal(List<Expense> weeklyExpenses) {
  return weeklyExpenses.fold(0, (sum, e) => sum + e.amount);
}
