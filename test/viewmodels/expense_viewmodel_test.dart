// test/viewmodels/expense_viewmodel_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/models/expense.dart';
import 'package:personal_expense_tracker/viewmodels/expense_viewmodel.dart';

import '../helpers/fake_expense_repository.dart';

Expense _makeExpense({
  String id = '1',
  String title = 'Coffee',
  double amount = 4.50,
  ExpenseCategory category = ExpenseCategory.food,
}) => Expense(
  id: id,
  title: title,
  amount: amount,
  date: DateTime(2024, 6, 1),
  category: category,
);

void main() {
  group('ExpenseViewModel', () {
    late ExpenseViewModel vm;
    late FakeExpenseRepository repo;

    setUp(() {
      repo = FakeExpenseRepository();
      vm = ExpenseViewModel(repository: repo);
    });

    tearDown(() => vm.dispose());

    // ── loadExpenses ───────────────────────────────────────────────────────────

    test('starts empty and in idle state', () {
      expect(vm.expenses, isEmpty);
      expect(vm.state, ViewState.idle);
    });

    test('loadExpenses populates expenses from repository', () async {
      final expense = _makeExpense();
      await repo.add(expense);

      await vm.loadExpenses();

      expect(vm.expenses.length, 1);
      expect(vm.expenses.first.title, 'Coffee');
      expect(vm.state, ViewState.idle);
    });

    // ── addExpense ─────────────────────────────────────────────────────────────

    test('addExpense increases list count and updates total', () async {
      final result = await vm.addExpense(
        title: 'Lunch',
        amount: 12.00,
        date: DateTime(2024, 6, 2),
        category: ExpenseCategory.food,
      );

      expect(result, isTrue);
      expect(vm.expenses.length, 1);
      expect(vm.totalAmount, 12.00);
    });

    test('addExpense assigns unique ids to each expense', () async {
      await vm.addExpense(
        title: 'A',
        amount: 1,
        date: DateTime.now(),
        category: ExpenseCategory.other,
      );
      await vm.addExpense(
        title: 'B',
        amount: 2,
        date: DateTime.now(),
        category: ExpenseCategory.other,
      );

      expect(vm.expenses[0].id, isNot(vm.expenses[1].id));
    });

    // ── deleteExpense ──────────────────────────────────────────────────────────

    test('deleteExpense removes the correct item', () async {
      await vm.addExpense(
        title: 'Uber',
        amount: 9.0,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
      );
      final id = vm.expenses.first.id;

      final result = await vm.deleteExpense(id);

      expect(result, isTrue);
      expect(vm.expenses, isEmpty);
    });

    // ── updateExpense ──────────────────────────────────────────────────────────

    test('updateExpense reflects new values in list', () async {
      await vm.addExpense(
        title: 'Gym',
        amount: 50.0,
        date: DateTime.now(),
        category: ExpenseCategory.health,
      );
      final original = vm.expenses.first;
      final updated = original.copyWith(title: 'Gym Membership', amount: 55.0);

      await vm.updateExpense(updated);

      expect(vm.expenses.first.title, 'Gym Membership');
      expect(vm.expenses.first.amount, 55.0);
    });

    // ── category filter ────────────────────────────────────────────────────────

    test('setFilter limits visible expenses to selected category', () async {
      await vm.addExpense(
        title: 'Coffee',
        amount: 4.0,
        date: DateTime.now(),
        category: ExpenseCategory.food,
      );
      await vm.addExpense(
        title: 'Bus',
        amount: 2.0,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
      );

      vm.setFilter(ExpenseCategory.food);

      expect(vm.expenses.length, 1);
      expect(vm.expenses.first.category, ExpenseCategory.food);
    });

    test('setFilter(null) shows all expenses', () async {
      await vm.addExpense(
        title: 'Coffee',
        amount: 4.0,
        date: DateTime.now(),
        category: ExpenseCategory.food,
      );
      await vm.addExpense(
        title: 'Bus',
        amount: 2.0,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
      );

      vm.setFilter(ExpenseCategory.food);
      vm.setFilter(null);

      expect(vm.expenses.length, 2);
    });

    // ── computed values ────────────────────────────────────────────────────────

    test('totalAmount sums only filtered expenses', () async {
      await vm.addExpense(
        title: 'Meal',
        amount: 15.0,
        date: DateTime.now(),
        category: ExpenseCategory.food,
      );
      await vm.addExpense(
        title: 'Train',
        amount: 3.0,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
      );

      vm.setFilter(ExpenseCategory.food);
      expect(vm.totalAmount, 15.0);
    });

    test('isEmpty returns true only when no expenses exist', () async {
      expect(vm.isEmpty, isTrue);

      await vm.addExpense(
        title: 'X',
        amount: 1.0,
        date: DateTime.now(),
        category: ExpenseCategory.other,
      );

      expect(vm.isEmpty, isFalse);
    });
  });
}
