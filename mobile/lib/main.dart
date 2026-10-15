import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/wallets/providers/wallet_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/budgets/providers/budget_provider.dart';
import 'features/reports/providers/report_provider.dart';
import 'features/savings_goals/providers/savings_goal_provider.dart';
import 'features/debts/providers/debt_provider.dart';
import 'features/bills/providers/bill_provider.dart';
import 'features/ai_advisor/providers/ai_advisor_provider.dart';
import 'features/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SavingsGoalProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => AiAdvisorProvider()),
      ],
      child: const MoneyFlowApp(),
    ),
  );
}

class MoneyFlowApp extends StatelessWidget {
  const MoneyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final auth = context.read<AuthProvider>();
    final isLoggedIn = await auth.checkAuthStatus();

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 52,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MoneyFlow',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản lý chi tiêu cá nhân thông minh & tối ưu tài chính',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
