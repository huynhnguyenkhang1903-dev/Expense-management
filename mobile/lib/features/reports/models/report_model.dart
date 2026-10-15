class DashboardSummaryModel {
  final double totalBalance;
  final double totalIncomeThisMonth;
  final double totalExpenseThisMonth;
  final double netSavingsThisMonth;
  final double totalBudgetThisMonth;
  final double totalBudgetSpentThisMonth;
  final int activeWalletsCount;
  final List<CategoryExpenseModel> topExpenseCategories;

  DashboardSummaryModel({
    required this.totalBalance,
    required this.totalIncomeThisMonth,
    required this.totalExpenseThisMonth,
    required this.netSavingsThisMonth,
    required this.totalBudgetThisMonth,
    required this.totalBudgetSpentThisMonth,
    required this.activeWalletsCount,
    required this.topExpenseCategories,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    var rawCategories = json['topExpenseCategories'] as List? ?? [];
    return DashboardSummaryModel(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
      totalIncomeThisMonth: (json['totalIncomeThisMonth'] as num?)?.toDouble() ?? 0.0,
      totalExpenseThisMonth: (json['totalExpenseThisMonth'] as num?)?.toDouble() ?? 0.0,
      netSavingsThisMonth: (json['netSavingsThisMonth'] as num?)?.toDouble() ?? 0.0,
      totalBudgetThisMonth: (json['totalBudgetThisMonth'] as num?)?.toDouble() ?? 0.0,
      totalBudgetSpentThisMonth: (json['totalBudgetSpentThisMonth'] as num?)?.toDouble() ?? 0.0,
      activeWalletsCount: json['activeWalletsCount'] ?? 0,
      topExpenseCategories: rawCategories
          .map((c) => CategoryExpenseModel.fromJson(c))
          .toList(),
    );
  }
}

class CategoryExpenseModel {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double totalAmount;
  final double percentage;
  final int transactionCount;

  CategoryExpenseModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });

  factory CategoryExpenseModel.fromJson(Map<String, dynamic> json) {
    return CategoryExpenseModel(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? 'category',
      categoryColor: json['categoryColor'] ?? '#6B7280',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}

class CashFlowModel {
  final String periodLabel;
  final double income;
  final double expense;

  CashFlowModel({
    required this.periodLabel,
    required this.income,
    required this.expense,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      periodLabel: json['periodLabel'] ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
