import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test database connection
  await testDatabaseConnection();
  
  runApp(const MyApp());
}

Future<void> testDatabaseConnection() async {
  try {
    print('Testing database connection...');
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    print('✅ Database connected successfully!');
    
    // Test categories
    final categories = await dbHelper.getAllCategories();
    print('✅ Loaded ${categories.length} categories');
    
    // Test expenses
    final expenses = await dbHelper.getAllExpenses();
    print('✅ Loaded ${expenses.length} expenses');
    
  } catch (e) {
    print('❌ Database error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}