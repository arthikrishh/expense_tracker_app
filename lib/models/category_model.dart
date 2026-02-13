class Category {
  final String id;
  final String name;
  final int color;
  final String icon;
  final double budget;
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.budget = 0,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'budget': budget,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      budget: map['budget'] ?? 0,
      isCustom: map['isCustom'] == 1,
    );
  }
}