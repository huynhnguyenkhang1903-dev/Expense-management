import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../../wallets/screens/transfer_screen.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/widgets/ai_receipt_scanner_sheet.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../reports/providers/report_provider.dart';
import '../../ai_advisor/providers/ai_advisor_provider.dart';
import '../../ai_advisor/widgets/health_score_sheet.dart';
import '../../ai_advisor/widgets/ai_advisor_chat_sheet.dart';
import '../../savings_goals/screens/savings_goals_screen.dart';
import '../../debts/screens/debts_screen.dart';
import '../../bills/screens/bills_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<WalletProvider>().fetchWallets(),
      context.read<TransactionProvider>().fetchCategories(),
      context.read<TransactionProvider>().fetchTransactions(),
      context.read<BudgetProvider>().fetchBudgets(),
      context.read<ReportProvider>().fetchDashboardSummary(),
      context.read<AiAdvisorProvider>().fetchHealthScore(),
    ]);
  }

  void _showHealthScoreSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HealthScoreSheet(),
    );
  }

  void _showAiChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiAdvisorChatSheet(),
    );
  }

  void _showScannerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiReceiptScannerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final walletProv = context.watch<WalletProvider>();
    final txProv = context.watch<TransactionProvider>();
    final reportProv = context.watch<ReportProvider>();
    final aiProv = context.watch<AiAdvisorProvider>();

    final user = auth.currentUser;
    final summary = reportProv.dashboardSummary;
    final healthScore = aiProv.healthScore;
    final isMasked = aiProv.isBalanceMasked;

    final totalBalance = walletProv.totalBalance;
    final totalIncome = summary?.totalIncomeThisMonth ?? 0.0;
    final totalExpense = summary?.totalExpenseThisMonth ?? 0.0;

    final totalBudget = summary?.totalBudgetThisMonth ?? 0.0;
    final budgetPercentage = totalBudget > 0 ? (totalExpense / totalBudget) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.vipGold, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF162032),
                child: Text(
                  user != null && user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'V',
                  style: const TextStyle(color: AppTheme.vipGold, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user?.fullName ?? 'Khách Hàng',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 14),
                    ],
                  ),
                  const Text('MONEYFLOW PRIVATE VIP', style: TextStyle(fontSize: 10, color: AppTheme.vipGold, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Health Score Pill Button
          if (healthScore != null)
            GestureDetector(
              onTap: _showHealthScoreSheet,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.vipCardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${healthScore.score} · ${healthScore.ratingGrade}',
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isMasked ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.textSecondary,
              size: 22,
            ),
            onPressed: () => aiProv.toggleBalanceMask(),
            tooltip: 'Ẩn/hiện số dư riêng tư',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardColor,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thẻ Obsidian Private Banking Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: AppTheme.vipCardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, color: AppTheme.vipGold, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'MONEYFLOW INFINITE PRIVILEGE',
                              style: TextStyle(
                                color: AppTheme.vipGold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppTheme.emeraldGlowGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VIP ACTIVE',
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isMasked ? '•••••••••• ₫' : CurrencyFormatter.formatVND(totalBalance),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tổng giá trị tài sản ròng khả dụng',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_downward_rounded, color: AppTheme.income, size: 14),
                                    SizedBox(width: 4),
                                    Text('Thu nhập tháng', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isMasked ? '••••••' : CurrencyFormatter.formatVND(totalIncome),
                                  style: const TextStyle(color: AppTheme.income, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 32, color: const Color(0xFF1E293B)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_upward_rounded, color: AppTheme.expense, size: 14),
                                    SizedBox(width: 4),
                                    Text('Chi tiêu tháng', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isMasked ? '••••••' : CurrencyFormatter.formatVND(totalExpense),
                                  style: const TextStyle(color: AppTheme.expense, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // AI Insights Banner (Cố Vấn Thông Minh)
              if (healthScore != null && healthScore.topInsights.isNotEmpty) ...[
                Builder(
                  builder: (context) {
                    final topInsight = healthScore.topInsights.first;
                    return InkWell(
                      onTap: _showAiChatSheet,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF172554), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.info.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: AppTheme.info, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        topInsight.title,
                                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    topInsight.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // VIP Quick Action Hub (6 Tiện Ích Đỉnh Cao)
              const Text(
                'TIỆN ÍCH TÀI CHÍNH VIP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.document_scanner_rounded,
                      label: 'Quét OCR AI',
                      color: AppTheme.primary,
                      onTap: _showScannerSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.smart_toy_rounded,
                      label: 'Cố Vấn AI',
                      color: AppTheme.info,
                      onTap: _showAiChatSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.savings_rounded,
                      label: 'Hũ Tiết Kiệm',
                      color: AppTheme.vipGold,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsGoalsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.handshake_rounded,
                      label: 'Sổ Ghi Nợ',
                      color: AppTheme.secondary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.receipt_long_rounded,
                      label: 'Hóa Đơn',
                      color: AppTheme.warning,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Chuyển Ví',
                      color: AppTheme.primaryLight,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ngân sách tháng Card
              if (totalBudget > 0) ...[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hạn mức chi tiêu tháng',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (budgetPercentage > 1.0
                                      ? AppTheme.expense
                                      : (budgetPercentage > 0.8 ? AppTheme.warning : AppTheme.primary))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(budgetPercentage * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: budgetPercentage > 1.0
                                    ? AppTheme.expense
                                    : (budgetPercentage > 0.8 ? AppTheme.warning : AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: budgetPercentage.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            budgetPercentage > 1.0
                                ? AppTheme.expense
                                : (budgetPercentage > 0.8 ? AppTheme.warning : AppTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã chi: ${CurrencyFormatter.formatVND(totalExpense)}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          Text(
                            'Hạn mức: ${CurrencyFormatter.formatVND(totalBudget)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Giao dịch gần đây
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                      );
                    },
                    child: const Text('Thêm mới', style: TextStyle(color: AppTheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (txProv.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ))
              else if (txProv.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Center(
                    child: Text('Chưa có giao dịch nào gần đây.', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                )
              else
                ...txProv.transactions.take(5).map((t) {
                  final isExp = t.isExpense;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isExp ? AppTheme.expense : AppTheme.income).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isExp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: isExp ? AppTheme.expense : AppTheme.income,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.categoryName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textPrimary),
                              ),
                              Text(
                                t.walletName,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isExp ? '-' : '+'}${CurrencyFormatter.formatVND(t.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isExp ? AppTheme.expense : AppTheme.income,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
