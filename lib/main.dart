// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/expense_repository.dart';
import 'screens/expense_list_screen.dart';
import 'theme/app_theme.dart';
import 'viewmodels/expense_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseViewModel(repository: LocalExpenseRepository()),
      child: MaterialApp(
        title: 'Personal Expense Tracker',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const ExpenseListScreen(),
      ),
    );
  }
}
