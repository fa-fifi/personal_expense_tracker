// test/models/expense_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/models/expense.dart';

void main() {
  group('Expense', () {
    final expense = Expense(
      id: 'abc-123',
      title: 'Lunch',
      amount: 12.50,
      date: DateTime(2024, 6, 15),
      category: ExpenseCategory.food,
      note: 'Team lunch',
    );

    test('toMap produces correct keys and values', () {
      final map = expense.toMap();

      expect(map['id'], 'abc-123');
      expect(map['title'], 'Lunch');
      expect(map['amount'], 12.50);
      expect(map['category'], 'food');
      expect(map['note'], 'Team lunch');
    });

    test('fromMap reconstructs identical object', () {
      final map = expense.toMap();
      final reconstructed = Expense.fromMap(map);

      expect(reconstructed.id, expense.id);
      expect(reconstructed.title, expense.title);
      expect(reconstructed.amount, expense.amount);
      expect(reconstructed.date, expense.date);
      expect(reconstructed.category, expense.category);
      expect(reconstructed.note, expense.note);
    });

    test('copyWith only changes specified fields', () {
      final modified = expense.copyWith(title: 'Dinner', amount: 20.0);

      expect(modified.title, 'Dinner');
      expect(modified.amount, 20.0);
      expect(modified.id, expense.id);
      expect(modified.category, expense.category);
    });

    test('fromMap falls back to other for unknown category', () {
      final map = expense.toMap()..['category'] = 'nonexistent';
      final result = Expense.fromMap(map);

      expect(result.category, ExpenseCategory.other);
    });
  });

  group('ExpenseCategory', () {
    test('every category has a non-empty label', () {
      for (final cat in ExpenseCategory.values) {
        expect(cat.label, isNotEmpty);
      }
    });

    test('every category has an emoji', () {
      for (final cat in ExpenseCategory.values) {
        expect(cat.emoji, isNotEmpty);
      }
    });
  });
}
