import 'package:expense_tracker_app/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;
  String _selectedPeriod = 'Month';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(expenseProvider, isDark),
              _buildCategoriesTab(expenseProvider, isDark),
              _buildTrendsTab(expenseProvider, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(ExpenseProvider provider, bool isDark) {
    final monthlySummary = provider.getMonthlySummary(_selectedDate);
    final weeklyData = provider.getWeeklySpending();
    final categorySpending = provider.getCategorySpendingWithBudget();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(isDark),
          const SizedBox(height: 20),

          // Main Stats Cards
          _buildMainStats(monthlySummary, isDark),
          const SizedBox(height: 20),

          // Weekly Spending Chart
          _buildSectionTitle('Weekly Spending', isDark),
          const SizedBox(height: 10),
          _buildWeeklyChart(weeklyData, isDark),
          const SizedBox(height: 20),

          // Budget Progress
          _buildSectionTitle('Budget Overview', isDark),
          const SizedBox(height: 10),
          ..._buildBudgetProgress(categorySpending, isDark),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(ExpenseProvider provider, bool isDark) {
    final categorySpending = provider.getCategorySpendingWithBudget();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pie Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(isDark),
            child: _buildPieChart(provider.expensesByCategory, provider),
          ),
          const SizedBox(height: 20),

          // Category List
          ...categorySpending.map((item) => _buildCategoryListItem(item, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ExpenseProvider provider, bool isDark) {
    final monthlyTrends = provider.getMonthlyTrends();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Monthly Trend Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(isDark),
            child: _buildMonthlyTrendChart(monthlyTrends, isDark),
          ),
          const SizedBox(height: 20),

          // Insights
          _buildInsightsCard(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['Week', 'Month', 'Year'].map((period) {
          bool isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.blue[700] : Colors.blue)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainStats(Map<String, dynamic> summary, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '₹${summary['total'].toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Average',
            '₹${summary['average'].toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.green,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Count',
            '${summary['count']}',
            Icons.receipt,
            Colors.orange,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Map<String, double> data, bool isDark) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(isDark),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.values.isEmpty ? 100 : data.values.reduce((a, b) => a > b ? a : b),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blue,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '₹${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.keys.length) {
                    return Text(
                      data.keys.elementAt(value.toInt()),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.entries.map((entry) {
            return BarChartGroupData(
              x: data.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, ExpenseProvider provider) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final category = provider.getCategoryById(entry.key);
          return PieChartSectionData(
            value: entry.value,
            title: '₹${entry.value.toStringAsFixed(0)}',
            color: Color(category?.color ?? Colors.grey.value),
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(Map<String, double> data, bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.keys.length) {
                  return Text(
                    data.keys.elementAt(value.toInt()),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.entries.map((entry) {
              return FlSpot(
                data.keys.toList().indexOf(entry.key).toDouble(),
                entry.value,
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBudgetProgress(List<Map<String, dynamic>> categorySpending, bool isDark) {
    return categorySpending.map((item) {
      final category = item['category'] as Category;
      final spent = item['spent'] as double;
      final budget = item['budget'] as double;
      final progress = item['progress'] as double;
      final isOverBudget = item['isOverBudget'] as bool;

      if (budget == 0) return const SizedBox();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _buildCardDecoration(isDark),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(category.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(category.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? Colors.red : Color(category.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${spent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : null,
                      ),
                    ),
                    Text(
                      '/ ₹${budget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Over budget by ₹${(spent - budget).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCategoryListItem(Map<String, dynamic> item, bool isDark) {
    final category = item['category'] as Category;
    final spent = item['spent'] as double;
    final budget = item['budget'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(category.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                if (budget > 0)
                  Text(
                    'Budget: ₹${budget.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${spent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              if (budget > 0)
                Text(
                  '${((spent / budget) * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: spent > budget ? Colors.red : Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(ExpenseProvider provider, bool isDark) {
    final monthlySummary = provider.getMonthlySummary(DateTime.now());
    final totalExpenses = provider.totalExpenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_down,
            'Spending Trend',
            'You spend ${_getSpendingTrend(monthlySummary)} on average',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.category,
            'Top Category',
            _getTopCategoryInsight(provider),
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.savings,
            'Saving Potential',
            _getSavingInsight(monthlySummary),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildCardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.grey[800] : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.grey[800],
      ),
    );
  }

  String _getSpendingTrend(Map<String, dynamic> summary) {
    double dailyAvg = summary['daily average'];
    if (dailyAvg < 500) return 'moderately';
    if (dailyAvg < 1000) return 'averagely';
    return 'highly';
  }

  String _getTopCategoryInsight(ExpenseProvider provider) {
    final categorySpending = provider.getCategorySpendingWithBudget();
    if (categorySpending.isEmpty) return 'No data available';
    
    categorySpending.sort((a, b) => (b['spent'] as double).compareTo(a['spent'] as double));
    final topCategory = categorySpending.first;
    final category = topCategory['category'] as Category;
    final spent = topCategory['spent'] as double;
    final percentage = (spent / provider.totalExpenses * 100).toStringAsFixed(1);
    
    return '${category.name} (${category.icon}) takes $percentage% of your spending';
  }

  String _getSavingInsight(Map<String, dynamic> summary) {
    double dailyAvg = summary['daily average'];
    double monthlyPotential = dailyAvg * 30 * 0.2; // 20% saving potential
    
    if (dailyAvg > 1000) {
      return 'You could save ₹${monthlyPotential.toStringAsFixed(2)} monthly';
    }
    return 'Your spending is already optimized';
  }
}