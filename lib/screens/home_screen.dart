import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/add_expense_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/expense_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${expenseProvider.totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${expenseProvider.getExpensesForMonth(_selectedDate).fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month - 1,
                                    );
                                  });
                                },
                              ),
                              Text(
                                DateFormat('MMM yyyy').format(_selectedDate),
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month + 1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expenses List
              Expanded(
                child: ListView.builder(
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    final category = expenseProvider.getCategoryById(expense.categoryId);
                    
                    if (category == null) return const SizedBox();
                    
                    return ExpenseCard(
                      expense: expense,
                      category: category,
                      onTap: () {
                        // Navigate to edit expense screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpenseScreen(expense: expense),
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteDialog(context, expense.id);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false)
                  .deleteExpense(expenseId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}