class CategoryModel {
  final String id;
  final String name;
  final int type; // 1 = Expense, 2 = Income
  final String icon;
  final String color;
  final bool isSystemDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isSystemDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 1,
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#6B7280',
      isSystemDefault: json['isSystemDefault'] ?? false,
    );
  }
}
