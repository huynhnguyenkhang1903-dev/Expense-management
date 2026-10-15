class BillModel {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String? walletId;
  final String? walletName;
  final DateTime dueDate;
  final String frequency;
  final String status;
  final int remindDaysBefore;
  final int daysRemaining;
  final bool isOverdue;
  final DateTime? lastPaidDate;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.walletId,
    this.walletName,
    required this.dueDate,
    required this.frequency,
    required this.status,
    required this.remindDaysBefore,
    required this.daysRemaining,
    required this.isOverdue,
    this.lastPaidDate,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? 'Hóa đơn',
      categoryIcon: json['categoryIcon'] ?? 'receipt',
      walletId: json['walletId'],
      walletName: json['walletName'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      frequency: json['frequency'] ?? 'Monthly',
      status: json['status'] ?? 'Pending',
      remindDaysBefore: json['remindDaysBefore'] ?? 3,
      daysRemaining: json['daysRemaining'] ?? 0,
      isOverdue: json['isOverdue'] ?? false,
      lastPaidDate: json['lastPaidDate'] != null ? DateTime.tryParse(json['lastPaidDate']) : null,
    );
  }
}
