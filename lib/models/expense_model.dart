class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? notes;
  final String? receiptUrl;
  final bool isRecurring;
  final String? recurringFrequency;
  final List<String>? tags;
  final String? location;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.notes,
    this.receiptUrl,
    this.isRecurring = false,
    this.recurringFrequency,
    this.tags,
    this.location,
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
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
      'tags': tags?.join(','),
      'location': location,
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
      isRecurring: map['isRecurring'] == 1,
      recurringFrequency: map['recurringFrequency'],
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
      location: map['location'],
    );
  }
}

