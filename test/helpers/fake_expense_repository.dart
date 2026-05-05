// test/helpers/fake_expense_repository.dart

import 'package:personal_expense_tracker/models/expense.dart';
import 'package:personal_expense_tracker/repositories/expense_repository.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> _store = [];

  /// Pre-seed data for tests
  FakeExpenseRepository([List<Expense> initial = const []]) {
    _store.addAll(initial);
  }

  @override
  Future<List<Expense>> getAll() async => List.from(_store);

  @override
  Future<void> add(Expense expense) async => _store.add(expense);

  @override
  Future<void> update(Expense expense) async {
    final index = _store.indexWhere((e) => e.id == expense.id);
    if (index != -1) _store[index] = expense;
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((e) => e.id == id);
  }
}
