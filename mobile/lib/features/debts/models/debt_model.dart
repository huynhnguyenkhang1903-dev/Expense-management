class DebtModel {
  final String id;
  final String personName;
  final String type; // Borrow hoặc Lend
  final double principalAmount;
  final double remainingAmount;
  final double paidAmount;
  final double repaymentProgress;
  final DateTime? dueDate;
  final String status;
  final String? note;
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.personName,
    required this.type,
    required this.principalAmount,
    required this.remainingAmount,
    required this.paidAmount,
    required this.repaymentProgress,
    this.dueDate,
    required this.status,
    this.note,
    required this.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] ?? '',
      personName: json['personName'] ?? '',
      type: json['type'] ?? 'Borrow',
      principalAmount: (json['principalAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      repaymentProgress: (json['repaymentProgress'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      status: json['status'] ?? 'Active',
      note: json['note'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class DebtSummaryModel {
  final double totalPayable;
  final double totalReceivable;
  final int activeDebtsCount;
  final List<DebtModel> debts;

  DebtSummaryModel({
    required this.totalPayable,
    required this.totalReceivable,
    required this.activeDebtsCount,
    required this.debts,
  });

  factory DebtSummaryModel.fromJson(Map<String, dynamic> json) {
    return DebtSummaryModel(
      totalPayable: (json['totalPayable'] ?? 0).toDouble(),
      totalReceivable: (json['totalReceivable'] ?? 0).toDouble(),
      activeDebtsCount: json['activeDebtsCount'] ?? 0,
      debts: (json['debts'] as List<dynamic>?)
              ?.map((d) => DebtModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}
