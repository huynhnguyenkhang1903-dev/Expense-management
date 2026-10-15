class WalletModel {
  final String id;
  final String name;
  final int type;
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final String colorCode;
  final String iconName;
  final bool isExcludedFromTotal;

  WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    required this.currency,
    required this.colorCode,
    required this.iconName,
    required this.isExcludedFromTotal,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 1,
      initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'VND',
      colorCode: json['colorCode'] ?? '#3B82F6',
      iconName: json['iconName'] ?? 'wallet',
      isExcludedFromTotal: json['isExcludedFromTotal'] ?? false,
    );
  }

  String get typeName {
    switch (type) {
      case 1:
        return 'Tiền mặt';
      case 2:
        return 'Tài khoản ngân hàng';
      case 3:
        return 'Ví điện tử';
      case 4:
        return 'Thẻ tín dụng';
      default:
        return 'Khác';
    }
  }
}
