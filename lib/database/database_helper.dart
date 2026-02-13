import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    
    // Delete existing database if you want to reset (optional)
    // await deleteDatabase(path);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        print('Database opened successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');
    
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL
      )
    ''');
    print('Categories table created');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        notes TEXT,
        receiptUrl TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    print('Expenses table created');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    print('Inserting default categories...');
    
    List<Category> defaultCategories = [
      Category(id: '1', name: 'Food', color: 0xFFFF5722, icon: '🍔'),
      Category(id: '2', name: 'Transport', color: 0xFF2196F3, icon: '🚗'),
      Category(id: '3', name: 'Shopping', color: 0xFF4CAF50, icon: '🛍️'),
      Category(id: '4', name: 'Entertainment', color: 0xFFFF9800, icon: '🎬'),
      Category(id: '5', name: 'Bills', color: 0xFF9C27B0, icon: '📄'),
      Category(id: '6', name: 'Healthcare', color: 0xFFE91E63, icon: '🏥'),
      Category(id: '7', name: 'Education', color: 0xFF00BCD4, icon: '📚'),
      Category(id: '8', name: 'Other', color: 0xFF607D8B, icon: '📦'),
    ];

    for (var category in defaultCategories) {
      try {
        await db.insert('categories', category.toMap());
        print('Inserted category: ${category.name}');
      } catch (e) {
        print('Error inserting category ${category.name}: $e');
      }
    }
  }

  // Expense CRUD Operations
  Future<int> insertExpense(Expense expense) async {
    try {
      Database db = await database;
      print('Inserting expense: ${expense.title}');
      return await db.insert('expenses', expense.toMap());
    } catch (e) {
      print('Error inserting expense: $e');
      return -1;
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        orderBy: 'date DESC'
      );
      print('Retrieved ${maps.length} expenses');
      return List.generate(maps.length, (i) {
        return Expense.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting expenses: $e');
      return [];
    }
  }

  Future<Expense?> getExpense(String id) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Expense.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting expense: $e');
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    try {
      Database db = await database;
      return await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      print('Error updating expense: $e');
      return 0;
    }
  }

  Future<int> deleteExpense(String id) async {
    try {
      Database db = await database;
      return await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting expense: $e');
      return 0;
    }
  }

  // Category Operations
  Future<List<Category>> getAllCategories() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('categories');
      print('Retrieved ${maps.length} categories');
      return List.generate(maps.length, (i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<Category?> getCategory(String id) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Category.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) {
        return Expense.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting expenses by date range: $e');
      return [];
    }
  }

  // Get total expenses for a period
  Future<double> getTotalExpensesForPeriod(DateTime start, DateTime end) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
      );
      double total = 0;
      for (var map in maps) {
        total += map['amount'] as double;
      }
      return total;
    } catch (e) {
      print('Error getting total expenses: $e');
      return 0;
    }
  }

  // Delete all expenses (for testing)
  Future<void> deleteAllExpenses() async {
    try {
      Database db = await database;
      await db.delete('expenses');
      print('All expenses deleted');
    } catch (e) {
      print('Error deleting all expenses: $e');
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}