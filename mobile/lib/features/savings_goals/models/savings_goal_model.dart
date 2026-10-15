class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final double remainingAmount;
  final DateTime? targetDate;
  final int? daysRemaining;
  final String status;
  final String color;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.remainingAmount,
    this.targetDate,
    this.daysRemaining,
    required this.status,
    required this.color,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      targetDate: json['targetDate'] != null ? DateTime.tryParse(json['targetDate']) : null,
      daysRemaining: json['daysRemaining'],
      status: json['status'] ?? 'InProgress',
      color: json['color'] ?? '#10B981',
    );
  }
}
