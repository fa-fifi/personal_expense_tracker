// lib/screens/expense_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/expense_viewmodel.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_header.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: 'About',
              onPressed: () => _showAbout(context),
            ),
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, vm, _) {
          // Show error banner if present
          if (vm.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(vm.errorMessage!),
                  backgroundColor: Colors.redAccent,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: vm.clearError,
                  ),
                ),
              );
              vm.clearError();
            });
          }

          if (vm.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.state == ViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text('Something went wrong'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: vm.loadExpenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (vm.isEmpty) {
            return EmptyStateWidget(
              onAddExpense: () => _navigateToAdd(context),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadExpenses,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SummaryHeader(
                    total: vm.totalAmountAll,
                    count: vm.expenses.length,
                    categoryTotals: vm.categoryTotals,
                    selectedCategory: vm.filterCategory,
                    onFilterChanged: vm.setFilter,
                  ),
                ),
                if (vm.expenses.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No expenses in this category.',
                        style: TextStyle(color: Color(0xFF9E9AB8)),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == vm.expenses.length) {
                        return const SizedBox(height: 90);
                      }
                      final expense = vm.expenses[index];
                      return ExpenseCard(
                        expense: expense,
                        onTap: () => _navigateToEdit(context, expense),
                        onDelete: () => vm.deleteExpense(expense.id),
                      );
                    }, childCount: vm.expenses.length + 1),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Future<void> _navigateToAdd(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  Future<void> _navigateToEdit(BuildContext context, expense) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(existingExpense: expense),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Built with Flutter · Take-home Assignment',
    );
  }
}
