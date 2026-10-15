import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().fetchBudgets();
      context.read<TransactionProvider>().fetchCategories();
    });
  }

  void _showAddBudgetDialog() {
    final limitController = TextEditingController();
    String? selectedCategoryId;
    final now = DateTime.now();

    final categories = context.read<TransactionProvider>().expenseCategories;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.borderSubtle),
          ),
          title: const Text('Thiết lập ngân sách', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: selectedCategoryId,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Danh mục chi tiêu'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tất cả danh mục (Ngân sách tổng)'),
                    ),
                    ...categories.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        )),
                  ],
                  onChanged: (val) => setDialogState(() => selectedCategoryId = val),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Hạn mức chi tiêu (₫)',
                    prefixIcon: Icon(Icons.attach_money, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final limitText = limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
                final limit = double.tryParse(limitText);

                if (limit == null || limit <= 0) return;

                final success = await context.read<BudgetProvider>().createOrUpdateBudget(
                  categoryId: selectedCategoryId,
                  limitAmount: limit,
                  month: now.month,
                  year: now.year,
                );

                if (context.mounted && success) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Lưu hạn mức'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProv = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản lý ngân sách tháng'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: budgetProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : budgetProv.budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade700),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có ngân sách nào cho tháng này',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddBudgetDialog,
                        child: const Text('Tạo ngân sách đầu tiên'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.cardColor,
                  onRefresh: () async => budgetProv.fetchBudgets(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: budgetProv.budgets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = budgetProv.budgets[index];
                      final pct = b.percentageUsed / 100.0;
                      final isOver = pct > 1.0;
                      final isWarning = pct >= 0.8 && !isOver;

                      final color = isOver
                          ? AppTheme.expense
                          : (isWarning ? AppTheme.warning : AppTheme.primary);

                      return Container(
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.account_balance_wallet, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    b.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${b.percentageUsed.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: const Color(0xFF1E293B),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đã chi: ${CurrencyFormatter.formatVND(b.spentAmount)}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                Text(
                                  'Hạn mức: ${CurrencyFormatter.formatVND(b.limitAmount)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            if (isOver) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.expense.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '⚠️ Đã vượt hạn mức: ${CurrencyFormatter.formatVND(b.spentAmount - b.limitAmount)}',
                                  style: const TextStyle(color: AppTheme.expense, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ] else if (isWarning) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '⚡ Cảnh báo: Đã sử dụng trên 80% hạn mức',
                                  style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
