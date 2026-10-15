class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String defaultCurrency;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.defaultCurrency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      defaultCurrency: json['defaultCurrency'] ?? 'VND',
    );
  }
}
