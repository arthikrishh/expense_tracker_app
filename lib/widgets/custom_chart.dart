import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const ExpenseChart({
    Key? key,
    required this.data,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: _buildSections(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    data.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '₹${amount.toStringAsFixed(0)}',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }
}