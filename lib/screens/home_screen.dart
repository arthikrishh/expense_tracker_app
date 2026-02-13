import 'package:expense_tracker_app/models/category_model.dart';
import 'package:expense_tracker_app/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/add_expense_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/expense_card.dart';
import '../services/pdf_export_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Fix: Add key for refresh indicator
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: LiquidPullToRefresh(
        key: _refreshIndicatorKey,
        color: Colors.blue,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        height: 100, // Reduced height for better performance
        onRefresh: () async {
          await Provider.of<ExpenseProvider>(context, listen: false).loadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern App Bar - Fixed with proper constraints
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [Colors.blue[900]!, Colors.purple[900]!]
                          : [Colors.blue[400]!, Colors.purple[400]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BackgroundPatternPainter(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Content with proper padding
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 16, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Greeting and welcome text - Fixed with Flexible
                            Flexible(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 30,
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          'Welcome Back!',
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          speed: const Duration(milliseconds: 100),
                                        ),
                                      ],
                                      totalRepeatCount: 1,
                                      isRepeatingAnimation: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Icons - Fixed with row that doesn't overflow
                            Flexible(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildIconButton(
                                    icon: Icons.bar_chart,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const StatisticsScreen()),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  _buildIconButton(
                                    icon: Icons.picture_as_pdf,
                                    onPressed: _exportToPDF,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildIconButton(
                                    icon: Icons.settings,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const SettingsScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Search bar in actions
              actions: [
                if (_isSearching)
                  Container(
                    width: size.width * 0.7, // Fixed width based on screen size
                    margin: const EdgeInsets.only(right: 8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7), size: 20),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search, size: 22),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
              ],
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80), // Space for FAB
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Consumer<ExpenseProvider>(
                        builder: (context, expenseProvider, child) {
                          if (expenseProvider.isLoading) {
                            return _buildShimmerLoading();
                          }

                          if (expenseProvider.error != null) {
                            return _buildErrorWidget(expenseProvider.error!);
                          }

                          final filteredExpenses = _filterExpenses(expenseProvider.expenses);
                          final monthlySummary = expenseProvider.getMonthlySummary(_selectedDate);

                          return Column(
                            children: [
                              // Monthly Summary Card - Fixed with proper constraints
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _buildMonthlySummaryCard(monthlySummary, expenseProvider, isDark),
                              ),
                              
                              // Date Navigator
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildDateNavigator(isDark),
                              ),
                              
                              // Category Spending Preview
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _buildCategoryPreview(expenseProvider, isDark),
                              ),
                              
                              // Recent Transactions Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Transactions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.grey[800],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to all transactions
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                                        );
                                      },
                                      child: const Text('View All →'),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Expenses List
                              if (filteredExpenses.isEmpty)
                                _buildEmptyState(isDark)
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: _buildExpensesList(filteredExpenses, expenseProvider),
                                ),
                              
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Fixed icon button with proper hit area
  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  // Fixed floating action button with proper touch feedback
  Widget _buildFloatingActionButton() {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 300),
      openBuilder: (context, _) => const AddExpenseScreen(),
      closedElevation: 6,
      closedShape: const CircleBorder(),
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  // Fixed monthly summary card with no RenderFlex issues
  Widget _buildMonthlySummaryCard(
    Map<String, dynamic> summary,
    ExpenseProvider provider,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.blue[800]!, Colors.purple[800]!]
              : [Colors.blue[400]!, Colors.purple[400]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.blue[900]! : Colors.blue[200]!).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row - Total and count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total expenses
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '₹${summary['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Transaction count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${summary['count']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Mini chart
          SizedBox(
            height: 40,
            child: _buildMiniChart(provider.getWeeklySpending()),
          ),
          
          const SizedBox(height: 16),
          
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avg/Day',
                '₹${(summary['daily average'] ?? 0).toStringAsFixed(0)}',
                Icons.trending_up,
              ),
              Container(
                height: 20,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                'Highest',
                summary['highestExpense'] != null
                    ? '₹${(summary['highestExpense'] as Expense).amount.toStringAsFixed(0)}'
                    : '₹0',
                Icons.arrow_upward,
              ),
              Container(
                height: 20,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              if (summary['mostUsedCategoryId'] != null)
                _buildStatItem(
                  'Top Cat',
                  provider.getCategoryById(summary['mostUsedCategoryId'])?.name.substring(0, 3) ?? '',
                  Icons.category,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Fixed stat item with proper constraints
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // Fixed mini chart
  Widget _buildMiniChart(Map<String, double> weeklyData) {
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final colors = [Colors.cyan, Colors.amber, Colors.orange, Colors.red, Colors.pink, Colors.purple, Colors.blue];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        String day = days[index];
        double amount = weeklyData[day] ?? 0;
        double maxAmount = weeklyData.values.isEmpty ? 1 : weeklyData.values.reduce((a, b) => a > b ? a : b);
        double barHeight = maxAmount > 0 ? (amount / maxAmount) * 30 : 0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: barHeight < 5 ? 5 : barHeight, // Minimum height for visibility
              width: 4,
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ],
        );
      }),
    );
  }

  // Fixed date navigator
  Widget _buildDateNavigator(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Fixed category preview
  Widget _buildCategoryPreview(ExpenseProvider provider, bool isDark) {
    final categorySpending = provider.getCategorySpendingWithBudget();
    final topCategories = categorySpending.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: topCategories.map((item) {
              final category = item['category'] as Category;
              final spent = item['spent'] as double;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Filter by category - could navigate to filtered view
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(category.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(category.color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹${spent.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Color(category.color),
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Fixed expenses list
  Widget _buildExpensesList(List<Expense> expenses, ExpenseProvider provider) {
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length > 5 ? 5 : expenses.length, // Show only 5 recent
        itemBuilder: (context, index) {
          final expense = expenses[index];
          final category = provider.getCategoryById(expense.categoryId);
          
          if (category == null) return const SizedBox();
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 300),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: ExpenseCard(
                  expense: expense,
                  category: category,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(expense: expense),
                      ),
                    );
                    if (result == true) {
                      // Refresh if needed
                    }
                  },
                  onDelete: () {
                    _showDeleteDialog(context, expense.id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Fixed empty state
  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first expense',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Fixed shimmer loading
  Widget _buildShimmerLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (index) => Container(
              height: 70,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Fixed error widget
  Widget _buildErrorWidget(String error) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Provider.of<ExpenseProvider>(context, listen: false).loadData();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<Expense> _filterExpenses(List<Expense> expenses) {
    if (_searchQuery.isEmpty) {
      return expenses.where((e) => 
        e.date.month == _selectedDate.month && 
        e.date.year == _selectedDate.year
      ).toList();
    }

    return expenses.where((e) {
      final matchesDate = e.date.month == _selectedDate.month && 
                          e.date.year == _selectedDate.year;
      final matchesSearch = e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          (e.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesDate && matchesSearch;
    }).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon ☕';
    } else {
      return 'Good Evening 🌙';
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      await PdfExportService.generateExpenseReport(
        provider.expenses,
        provider.categories,
        firstDayOfMonth,
        lastDayOfMonth,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF generated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false)
                  .deleteExpense(expenseId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Fixed background pattern painter
class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double spacing = 20;
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}