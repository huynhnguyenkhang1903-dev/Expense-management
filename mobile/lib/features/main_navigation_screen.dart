import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'dashboard/screens/dashboard_screen.dart';
import 'transactions/screens/transactions_screen.dart';
import 'budgets/screens/budgets_screen.dart';
import 'reports/screens/reports_screen.dart';
import 'settings/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.borderSubtle, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: const Color(0xFF0A0F1A),
          indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppTheme.primary),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primary),
              label: 'Giao dịch',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart, color: AppTheme.primary),
              label: 'Ngân sách',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
              label: 'Báo cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
