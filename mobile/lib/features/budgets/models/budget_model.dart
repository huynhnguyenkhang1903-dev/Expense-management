class BudgetModel {
  final String id;
  final String? categoryId;
  final String categoryName;
  final String categoryIcon;
  final double limitAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.month,
    required this.year,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'] ?? 'Ngân sách tổng',
      categoryIcon: json['categoryIcon'] ?? 'account_balance_wallet',
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentageUsed'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }
}
