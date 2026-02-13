import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/custom_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Month';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final expensesByCategory = expenseProvider.expensesByCategory;
          final chartColors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.teal,
            Colors.amber,
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPeriodChip('Week'),
                            _buildPeriodChip('Month'),
                            _buildPeriodChip('Year'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _previousPeriod,
                            ),
                            Text(
                              _getPeriodTitle(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _nextPeriod,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Expenses',
                        '₹${expenseProvider.totalExpenses.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Categories',
                        '${expenseProvider.categories.length}',
                        Icons.category,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expenses by Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: ExpenseChart(
                            data: expensesByCategory,
                            colors: chartColors,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category List
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...expensesByCategory.entries.map((entry) {
                          final category = expenseProvider.getCategoryById(entry.key);
                          if (category == null) return const SizedBox();
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(category.color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: entry.value / expenseProvider.totalExpenses,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(category.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '₹${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    return FilterChip(
      label: Text(period),
      selected: _selectedPeriod == period,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
        });
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodTitle() {
    if (_selectedPeriod == 'Week') {
      final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}';
    } else if (_selectedPeriod == 'Month') {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      return DateFormat('yyyy').format(_selectedDate);
    }
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedPeriod == 'Week') {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else if (_selectedPeriod == 'Month') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year - 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_selectedPeriod == 'Week') {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else if (_selectedPeriod == 'Month') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year + 1, 1);
      }
    });
  }
}