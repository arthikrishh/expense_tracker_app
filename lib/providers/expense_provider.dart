import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;

  ExpenseProvider() {
    loadData();
  }

  Future<void> loadData() async {
    await loadCategories();
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    _expenses = await _dbHelper.getAllExpenses();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _dbHelper.getAllCategories();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _dbHelper.deleteExpense(id);
    await loadExpenses();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  double get totalExpenses {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get expensesByCategory {
    Map<String, double> categoryExpenses = {};
    for (var expense in _expenses) {
      categoryExpenses.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryExpenses;
  }

  List<Expense> getExpensesForMonth(DateTime date) {
    return _expenses.where((expense) {
      return expense.date.month == date.month && 
             expense.date.year == date.year;
    }).toList();
  }

  Map<String, double> getDailyExpensesForMonth(DateTime date) {
    Map<String, double> dailyExpenses = {};
    for (var expense in getExpensesForMonth(date)) {
      String dayKey = DateFormat('yyyy-MM-dd').format(expense.date);
      dailyExpenses.update(
        dayKey,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return dailyExpenses;
  }
}