import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Tự động nhận diện nền tảng để trỏ đúng địa chỉ máy chủ API:
  // - Android Emulator: 10.0.2.2
  // - Windows / iOS Simulator / Web: localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:5000/api/v1';
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';

  static const String wallets = '/wallets';
  static const String transfer = '/wallets/transfer';

  static const String categories = '/categories';
  static const String transactions = '/transactions';

  static const String budgets = '/budgets';

  static const String dashboardReport = '/reports/dashboard';
  static const String categoryBreakdown = '/reports/category-breakdown';
  static const String monthlyCashFlow = '/reports/monthly-cashflow';

  // Enterprise VIP Endpoints
  static const String savingsGoals = '/savings-goals';
  static const String debts = '/debts';
  static const String bills = '/bills';
  static const String aiHealthScore = '/ai-advisor/health-score';
  static const String aiInsights = '/ai-advisor/insights';
  static const String aiChat = '/ai-advisor/chat';
  static const String exportCsv = '/export/csv';
  static const String auditLogs = '/export/audit-logs';
}
