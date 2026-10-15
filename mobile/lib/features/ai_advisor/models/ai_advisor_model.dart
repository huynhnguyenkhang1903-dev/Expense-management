class FinancialHealthScoreModel {
  final int score;
  final String ratingGrade;
  final String ratingTitle;
  final String ratingDescription;
  final double savingsRatePercentage;
  final double expenseToIncomeRatio;
  final double emergencyRunwayMonths;
  final double budgetDisciplinePercentage;
  final int savingsPillarScore;
  final int expensePillarScore;
  final int runwayPillarScore;
  final int budgetPillarScore;
  final List<FinancialInsightModel> topInsights;

  FinancialHealthScoreModel({
    required this.score,
    required this.ratingGrade,
    required this.ratingTitle,
    required this.ratingDescription,
    required this.savingsRatePercentage,
    required this.expenseToIncomeRatio,
    required this.emergencyRunwayMonths,
    required this.budgetDisciplinePercentage,
    required this.savingsPillarScore,
    required this.expensePillarScore,
    required this.runwayPillarScore,
    required this.budgetPillarScore,
    required this.topInsights,
  });

  factory FinancialHealthScoreModel.fromJson(Map<String, dynamic> json) {
    return FinancialHealthScoreModel(
      score: json['score'] ?? 500,
      ratingGrade: json['ratingGrade'] ?? 'A',
      ratingTitle: json['ratingTitle'] ?? 'Hạng Vàng',
      ratingDescription: json['ratingDescription'] ?? '',
      savingsRatePercentage: (json['savingsRatePercentage'] ?? 0).toDouble(),
      expenseToIncomeRatio: (json['expenseToIncomeRatio'] ?? 0).toDouble(),
      emergencyRunwayMonths: (json['emergencyRunwayMonths'] ?? 0).toDouble(),
      budgetDisciplinePercentage: (json['budgetDisciplinePercentage'] ?? 0).toDouble(),
      savingsPillarScore: json['savingsPillarScore'] ?? 150,
      expensePillarScore: json['expensePillarScore'] ?? 150,
      runwayPillarScore: json['runwayPillarScore'] ?? 150,
      budgetPillarScore: json['budgetPillarScore'] ?? 150,
      topInsights: (json['topInsights'] as List<dynamic>?)
              ?.map((i) => FinancialInsightModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class FinancialInsightModel {
  final String id;
  final String type;
  final String category;
  final String title;
  final String message;
  final String? actionText;
  final String impactLevel;

  FinancialInsightModel({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    this.actionText,
    required this.impactLevel,
  });

  factory FinancialInsightModel.fromJson(Map<String, dynamic> json) {
    return FinancialInsightModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'Tip',
      category: json['category'] ?? 'General',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actionText: json['actionText'],
      impactLevel: json['impactLevel'] ?? 'Medium',
    );
  }
}

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}
