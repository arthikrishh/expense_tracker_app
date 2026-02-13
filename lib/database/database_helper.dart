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
    
    // Delete existing database to recreate with new schema (only for development)
    // await deleteDatabase(path); // Uncomment this line to force delete
    
    return await openDatabase(
      path,
      version: 2, // Increment version number to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add upgrade handler
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT,
        color INTEGER,
        icon TEXT,
        budget REAL DEFAULT 0,
        isCustom INTEGER DEFAULT 0
      )
    ''');

    // Create expenses table with all new columns
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT,
        amount REAL,
        date TEXT,
        categoryId TEXT,
        notes TEXT,
        receiptUrl TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurringFrequency TEXT,
        tags TEXT,
        location TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  // Add upgrade handler for existing installations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to expenses table
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN isRecurring INTEGER DEFAULT 0');
      } catch (e) {
        print('Column isRecurring might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN recurringFrequency TEXT');
      } catch (e) {
        print('Column recurringFrequency might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN tags TEXT');
      } catch (e) {
        print('Column tags might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN location TEXT');
      } catch (e) {
        print('Column location might already exist: $e');
      }
      
      // Add new columns to categories table
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN budget REAL DEFAULT 0');
      } catch (e) {
        print('Column budget might already exist: $e');
      }
      
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN isCustom INTEGER DEFAULT 0');
      } catch (e) {
        print('Column isCustom might already exist: $e');
      }
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<Category> defaultCategories = [
      Category(id: '1', name: 'Food', color: 0xFFFF5722, icon: '🍔', budget: 0, isCustom: false),
      Category(id: '2', name: 'Transport', color: 0xFF2196F3, icon: '🚗', budget: 0, isCustom: false),
      Category(id: '3', name: 'Shopping', color: 0xFF4CAF50, icon: '🛍️', budget: 0, isCustom: false),
      Category(id: '4', name: 'Entertainment', color: 0xFFFF9800, icon: '🎬', budget: 0, isCustom: false),
      Category(id: '5', name: 'Bills', color: 0xFF9C27B0, icon: '📄', budget: 0, isCustom: false),
      Category(id: '6', name: 'Healthcare', color: 0xFFE91E63, icon: '🏥', budget: 0, isCustom: false),
      Category(id: '7', name: 'Education', color: 0xFF00BCD4, icon: '📚', budget: 0, isCustom: false),
      Category(id: '8', name: 'Other', color: 0xFF607D8B, icon: '📦', budget: 0, isCustom: false),
    ];

    for (var category in defaultCategories) {
      try {
        await db.insert('categories', category.toMap());
      } catch (e) {
        print('Category might already exist: $e');
      }
    }
  }

  // Expense CRUD Operations
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    try {
      print('Inserting expense: ${expense.title}');
      return await db.insert('expenses', expense.toMap());
    } catch (e) {
      print('Error inserting expense: $e');
      rethrow;
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date DESC');
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
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    Database db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category Operations
  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<Category?> getCategory(String id) async {
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
  }

  // Insert category
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  // Update category
  Future<int> updateCategory(Category category) async {
    Database db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete category
  Future<int> deleteCategory(String id) async {
    Database db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
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
  }

  // Clear all data
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('expenses');
    // Don't delete categories as they are default
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Get total by date range
  Future<double> getTotalByDateRange(DateTime start, DateTime end) async {
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
  }
}