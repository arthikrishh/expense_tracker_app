class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? notes;
  final String? receiptUrl;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.notes,
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'notes': notes,
      'receiptUrl': receiptUrl,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      notes: map['notes'],
      receiptUrl: map['receiptUrl'],
    );
  }
}