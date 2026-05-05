// lib/repositories/expense_repository.dart

import '../data/database_helper.dart';
import '../models/expense.dart';

/// Abstract interface — makes the ViewModel testable against a fake/mock.
abstract class ExpenseRepository {
  Future<List<Expense>> getAll();
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
}

class LocalExpenseRepository implements ExpenseRepository {
  final DatabaseHelper _db;

  LocalExpenseRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  @override
  Future<List<Expense>> getAll() => _db.getAllExpenses();

  @override
  Future<void> add(Expense expense) => _db.insertExpense(expense);

  @override
  Future<void> update(Expense expense) => _db.updateExpense(expense);

  @override
  Future<void> delete(String id) => _db.deleteExpense(id);
}
