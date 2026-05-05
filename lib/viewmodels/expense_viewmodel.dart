// lib/viewmodels/expense_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../repositories/expense_repository.dart';

enum ViewState { idle, loading, error }

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;
  final _uuid = const Uuid();

  ExpenseViewModel({required ExpenseRepository repository})
    : _repository = repository;

  List<Expense> _expenses = [];
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  ExpenseCategory? _filterCategory;

  // ── Getters ─────────────────────────────────────────────────────────────────

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  ExpenseCategory? get filterCategory => _filterCategory;

  List<Expense> get expenses {
    if (_filterCategory == null) return _expenses;
    return _expenses.where((e) => e.category == _filterCategory).toList();
  }

  double get totalAmount => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get totalAmountAll => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get categoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  bool get isEmpty => _expenses.isEmpty;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> loadExpenses() async {
    _setState(ViewState.loading);
    try {
      _expenses = await _repository.getAll();
      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = 'Failed to load expenses. Please try again.';
      _setState(ViewState.error);
    }
  }

  Future<bool> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? note,
  }) async {
    try {
      final expense = Expense(
        id: _uuid.v4(),
        title: title.trim(),
        amount: amount,
        date: date,
        category: category,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
      );
      await _repository.add(expense);
      _expenses.insert(0, expense);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save expense.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(Expense updated) async {
    try {
      await _repository.update(updated);
      final index = _expenses.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _expenses[index] = updated;
        _expenses.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _repository.delete(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense.';
      notifyListeners();
      return false;
    }
  }

  void setFilter(ExpenseCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }
}
