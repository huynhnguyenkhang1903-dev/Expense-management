import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../models/savings_goal_model.dart';
import '../providers/savings_goal_provider.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsGoalProvider>().fetchGoals();
      context.read<WalletProvider>().fetchWallets();
    });
  }

  void _showCreateGoalSheet() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final initialCtrl = TextEditingController();
    String? selectedWalletId;
    final wallets = context.read<WalletProvider>().wallets;
    if (wallets.isNotEmpty) selectedWalletId = wallets.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Khởi Tạo Hũ Tiết Kiệm Mới',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Đặt mục tiêu tài chính để kích hoạt tính năng tích lũy tự động',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Tên mục tiêu',
                  hintText: 'Ví dụ: Mua MacBook Pro M4, Đi du lịch Nhật...',
                  prefixIcon: Icon(Icons.flag_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số tiền mục tiêu (₫)',
                  hintText: '50000000',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: initialCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Khoản nạp khởi đầu (Không bắt buộc)',
                  hintText: '1000000',
                  prefixIcon: Icon(Icons.savings_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              if (wallets.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedWalletId,
                  dropdownColor: const Color(0xFF131B2A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Ví trích tiền nạp khởi đầu',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary),
                  ),
                  items: wallets
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text('${w.name} (${CurrencyFormatter.formatVND(w.currentBalance)})'),
                          ))
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedWalletId = val),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    final initial = double.tryParse(initialCtrl.text.trim()) ?? 0;

                    if (name.isEmpty || target <= 0) return;

                    final success = await context.read<SavingsGoalProvider>().createGoal(
                          name: name,
                          targetAmount: target,
                          initialAmount: initial,
                          walletId: selectedWalletId,
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã tạo hũ tích lũy thành công!')),
                      );
                    }
                  },
                  child: const Text('Xác Nhận Tạo Hũ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepositSheet(SavingsGoalModel goal) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final wallets = context.read<WalletProvider>().wallets;
    String? selectedWalletId = wallets.isNotEmpty ? wallets.first.id : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nạp Thêm Tiền Vào Hũ: ${goal.name}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Mục tiêu: ${CurrencyFormatter.formatVND(goal.targetAmount)} (Còn thiếu ${CurrencyFormatter.formatVND(goal.remainingAmount)})',
                style: const TextStyle(color: AppTheme.primary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Số tiền muốn nạp (₫)',
                  hintText: '500000',
                  prefixIcon: Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              if (wallets.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedWalletId,
                  dropdownColor: const Color(0xFF131B2A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Trích từ ví nguồn',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary),
                  ),
                  items: wallets
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text('${w.name} (${CurrencyFormatter.formatVND(w.currentBalance)})'),
                          ))
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedWalletId = val),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: noteCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (Tùy chọn)',
                  hintText: 'Thưởng quý trích vào hũ...',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (amount <= 0 || selectedWalletId == null) return;

                    final success = await context.read<SavingsGoalProvider>().depositToGoal(
                          goalId: goal.id,
                          walletId: selectedWalletId!,
                          amount: amount,
                          note: noteCtrl.text.trim(),
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      context.read<WalletProvider>().fetchWallets(); // Refresh wallet balances
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã nạp ${CurrencyFormatter.formatVND(amount)} vào hũ!')),
                      );
                    }
                  },
                  child: const Text('Xác Nhận Nạp Tiền'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hũ Tiết Kiệm & Quỹ Tích Lũy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 26),
            onPressed: _showCreateGoalSheet,
          ),
        ],
      ),
      body: Consumer<SavingsGoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (provider.goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: const Icon(Icons.savings_rounded, color: AppTheme.primary, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Chưa có Hũ Tiết Kiệm nào',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo mục tiêu để ứng dụng tự động theo dõi tiến độ và tối ưu lãi tích lũy',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Khởi Tạo Hũ Ngay'),
                      onPressed: _showCreateGoalSheet,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              return _buildGoalCard(goal);
            },
          );
        },
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoalModel goal) {
    final progress = (goal.progressPercentage / 100).clamp(0.0, 1.0);
    final isCompleted = goal.status == 'Completed' || goal.currentAmount >= goal.targetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? AppTheme.primary.withValues(alpha: 0.6) : AppTheme.borderSubtle,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.savings_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isCompleted
                            ? '🎉 Đã hoàn thành 100%'
                            : 'Tiến độ: ${goal.progressPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isCompleted ? AppTheme.primaryLight : AppTheme.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted, size: 20),
                onPressed: () => context.read<SavingsGoalProvider>().deleteGoal(goal.id),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Số tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Đã tích lũy', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatVND(goal.currentAmount),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Mục tiêu cần đạt', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatVND(goal.targetAmount),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Thanh tiến độ
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppTheme.primaryLight : AppTheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // Nút nạp thêm tiền
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nạp Thêm Vào Hũ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDepositSheet(goal),
              ),
            ),
        ],
      ),
    );
  }
}
