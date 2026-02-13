import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(category.color)
              : Color(category.color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Color(category.color),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(category.color),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}