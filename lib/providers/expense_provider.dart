import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpenseProvider() {
    loadData();
  }

  // Load all data
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadCategories();
      await loadExpenses();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load expenses from database
  Future<void> loadExpenses() async {
    _expenses = await _dbHelper.getAllExpenses();
    notifyListeners();
  }

  // Load categories from database
  Future<void> loadCategories() async {
    _categories = await _dbHelper.getAllCategories();
    notifyListeners();
  }

  // Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _dbHelper.insertExpense(expense);
      await loadExpenses(); // Reload to get updated list
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update existing expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await _dbHelper.updateExpense(expense);
      await loadExpenses(); // Reload to get updated list
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    try {
      await _dbHelper.deleteExpense(id);
      await loadExpenses(); // Reload to get updated list
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate total expenses
  double get totalExpenses {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  // Get expenses grouped by category
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

  // Get expenses for specific month
  List<Expense> getExpensesForMonth(DateTime date) {
    return _expenses.where((expense) {
      return expense.date.month == date.month && 
             expense.date.year == date.year;
    }).toList();
  }

  // Get daily expenses for month
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

  // Get monthly summary
  Map<String, dynamic> getMonthlySummary(DateTime date) {
    final monthlyExpenses = getExpensesForMonth(date);

    double total = monthlyExpenses.fold(0, (sum, e) => sum + e.amount);
    double average = monthlyExpenses.isNotEmpty ? total / monthlyExpenses.length : 0;
    
    // Get highest expense
    Expense? highestExpense;
    if (monthlyExpenses.isNotEmpty) {
      highestExpense = monthlyExpenses.reduce((a, b) => a.amount > b.amount ? a : b);
    }

    // Get most used category
    Map<String, int> categoryCount = {};
    for (var e in monthlyExpenses) {
      categoryCount[e.categoryId] = (categoryCount[e.categoryId] ?? 0) + 1;
    }
    
    String? mostUsedCategoryId;
    int maxCount = 0;
    categoryCount.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostUsedCategoryId = key;
      }
    });

    // Calculate daily average for the month
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    double dailyAverage = monthlyExpenses.isNotEmpty ? total / daysInMonth : 0;

    return {
      'total': total,
      'average': average,
      'count': monthlyExpenses.length,
      'highestExpense': highestExpense,
      'mostUsedCategoryId': mostUsedCategoryId,
      'daily average': dailyAverage,
    };
  }

  // Get category spending with budget progress
  List<Map<String, dynamic>> getCategorySpendingWithBudget() {
    Map<String, double> spending = {};
    
    for (var expense in _expenses) {
      spending.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return _categories.map((category) {
      double spent = spending[category.id] ?? 0;
      double budget = category.budget;
      double progress = budget > 0 ? spent / budget : 0;
      bool isOverBudget = budget > 0 && spent > budget;

      return {
        'category': category,
        'spent': spent,
        'budget': budget,
        'progress': progress,
        'isOverBudget': isOverBudget,
        'remaining': budget - spent,
      };
    }).toList();
  }

  // Get weekly spending trends
  Map<String, double> getWeeklySpending() {
    Map<String, double> weeklyData = {};
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(const Duration(days: 7));

    // Initialize all days with 0
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var day in days) {
      weeklyData[day] = 0;
    }

    // Calculate spending for each day
    for (var expense in _expenses) {
      if (expense.date.isAfter(weekAgo)) {
        String day = DateFormat('EEE').format(expense.date);
        weeklyData.update(
          day,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    return weeklyData;
  }

  // Get monthly trends for last 6 months
  Map<String, double> getMonthlyTrends() {
    Map<String, double> monthlyData = {};
    DateTime now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String monthKey = DateFormat('MMM').format(date);
      
      double total = _expenses
          .where((e) => e.date.month == date.month && e.date.year == date.year)
          .fold(0, (sum, e) => sum + e.amount);
      
      monthlyData[monthKey] = total;
    }

    return monthlyData;
  }

  // Get expenses by category for pie chart
  Map<Category, double> getExpensesByCategoryWithObjects() {
    Map<Category, double> result = {};
    
    for (var expense in _expenses) {
      final category = getCategoryById(expense.categoryId);
      if (category != null) {
        result.update(
          category,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }
    
    return result;
  }

  // Get recent expenses (last 10)
  List<Expense> getRecentExpenses() {
    List<Expense> sorted = List.from(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  // Search expenses
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return _expenses;
    
    query = query.toLowerCase();
    return _expenses.where((expense) {
      final category = getCategoryById(expense.categoryId);
      return expense.title.toLowerCase().contains(query) ||
             (expense.notes?.toLowerCase().contains(query) ?? false) ||
             (category?.name.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    return await _dbHelper.getExpensesByDateRange(start, end);
  }

  // Get total by category for a specific month
  Map<String, double> getCategoryTotalsForMonth(DateTime date) {
    Map<String, double> totals = {};
    final monthlyExpenses = getExpensesForMonth(date);
    
    for (var expense in monthlyExpenses) {
      totals.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return totals;
  }

  // Add new category (for custom categories)
  Future<void> addCategory(Category category) async {
    try {
      await _dbHelper.insertCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update category
  Future<void> updateCategory(Category category) async {
    try {
      await _dbHelper.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete category (only if custom and no expenses)
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has any expenses
      bool hasExpenses = _expenses.any((e) => e.categoryId == id);
      if (hasExpenses) {
        throw Exception('Cannot delete category with existing expenses');
      }
      
      await _dbHelper.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get budget status
  Map<String, dynamic> getBudgetStatus() {
    double totalBudget = _categories.fold(0, (sum, cat) => sum + cat.budget);
    double totalSpent = totalExpenses;
    
    return {
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'remaining': totalBudget - totalSpent,
      'percentageUsed': totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0,
      'isOverBudget': totalBudget > 0 && totalSpent > totalBudget,
    };
  }

  // Get spending insights
  List<String> getSpendingInsights() {
    List<String> insights = [];
    final monthlySummary = getMonthlySummary(DateTime.now());
    final categorySpending = getCategorySpendingWithBudget();
    
    // Insight 1: Top spending category
    if (categorySpending.isNotEmpty) {
      categorySpending.sort((a, b) => (b['spent'] as double).compareTo(a['spent'] as double));
      final topCategory = categorySpending.first;
      final category = topCategory['category'] as Category;
      final spent = topCategory['spent'] as double;
      final percentage = (spent / totalExpenses * 100).toStringAsFixed(1);
      insights.add('Your highest spending category is ${category.name} (${category.icon}) at $percentage% of total expenses.');
    }
    
    // Insight 2: Daily average
    double dailyAvg = monthlySummary['daily average'];
    if (dailyAvg > 1000) {
      insights.add('Your daily average of ₹${dailyAvg.toStringAsFixed(2)} is on the higher side. Consider reviewing small expenses.');
    } else if (dailyAvg < 300) {
      insights.add('Great job keeping your daily expenses under ₹300!');
    }
    
    // Insight 3: Budget alerts
    for (var item in categorySpending) {
      if (item['isOverBudget'] as bool) {
        final category = item['category'] as Category;
        final spent = item['spent'] as double;
        final budget = item['budget'] as double;
        insights.add('You\'ve exceeded your ${category.name} budget by ₹${(spent - budget).toStringAsFixed(2)}.');
      }
    }
    
    // Insight 4: Saving opportunity
    double potentialSavings = dailyAvg * 30 * 0.1; // 10% saving potential
    if (potentialSavings > 500) {
      insights.add('You could potentially save ₹${potentialSavings.toStringAsFixed(2)} per month by reducing daily expenses by just 10%.');
    }
    
    return insights;
  }

  // Clear all data (for settings)
  Future<void> clearAllData() async {
    try {
      await _dbHelper.clearAllData();
      await loadData(); // Reload everything
    } catch (e) {
      _error = 'Failed to clear data: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Export data as CSV format
  String exportAsCSV() {
    StringBuffer csv = StringBuffer();
    
    // Add headers
    csv.writeln('Date,Title,Amount,Category,Notes');
    
    // Add expenses
    for (var expense in _expenses) {
      final category = getCategoryById(expense.categoryId);
      csv.writeln(
        '${DateFormat('yyyy-MM-dd').format(expense.date)},'
        '${expense.title},'
        '${expense.amount},'
        '${category?.name ?? 'Unknown'},'
        '${expense.notes ?? ''}'
      );
    }
    
    return csv.toString();
  }
}