import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.category,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withOpacity(0.2),
          child: Text(
            category.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name),
            Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}