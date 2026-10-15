class TransactionModel {
  final String id;
  final String walletId;
  final String walletName;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final int type; // 1 = Expense, 2 = Income
  final double amount;
  final DateTime transactionDate;
  final String? note;
  final String? imageUrl;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.walletName,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.type,
    required this.amount,
    required this.transactionDate,
    this.note,
    this.imageUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      walletId: json['walletId'] ?? '',
      walletName: json['walletName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? 'receipt',
      categoryColor: json['categoryColor'] ?? '#6B7280',
      type: json['type'] ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: DateTime.tryParse(json['transactionDate'] ?? '') ?? DateTime.now(),
      note: json['note'],
      imageUrl: json['imageUrl'],
    );
  }

  bool get isExpense => type == 1;
}
