import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../models/debt_model.dart';
import '../providers/debt_provider.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().fetchDebtsSummary();
      context.read<WalletProvider>().fetchWallets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateDebtSheet() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedType = _tabController.index == 0 ? 'Lend' : 'Borrow';
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
                'Ghi Nhận Khoản Nợ / Cho Vay',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Segmented selector (Cho vay vs Tôi nợ)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setSheetState(() => selectedType = 'Lend'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == 'Lend' ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == 'Lend' ? AppTheme.primary : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cho Vay (Phải Thu)',
                            style: TextStyle(
                              color: selectedType == 'Lend' ? AppTheme.primary : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setSheetState(() => selectedType = 'Borrow'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == 'Borrow' ? AppTheme.expense.withValues(alpha: 0.2) : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == 'Borrow' ? AppTheme.expense : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Tôi Nợ (Phải Trả)',
                            style: TextStyle(
                              color: selectedType == 'Borrow' ? AppTheme.expense : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: selectedType == 'Lend' ? 'Tên người vay nợ tôi' : 'Tên chủ nợ',
                  hintText: 'Ví dụ: Anh Nam, Bạn Trang...',
                  prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số tiền (₫)',
                  hintText: '5000000',
                  prefixIcon: Icon(Icons.monetization_on_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              if (wallets.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedWalletId,
                  dropdownColor: const Color(0xFF131B2A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Ví thực hiện giao dịch (Tùy chọn)',
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
                  labelText: 'Ghi chú',
                  hintText: 'Hẹn cuối tháng trả...',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || amount <= 0) return;

                    final success = await context.read<DebtProvider>().createDebt(
                          personName: name,
                          type: selectedType,
                          principalAmount: amount,
                          walletId: selectedWalletId,
                          note: noteCtrl.text.trim(),
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      context.read<WalletProvider>().fetchWallets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã ghi nhận sổ nợ thành công!')),
                      );
                    }
                  },
                  child: const Text('Lưu Sổ Ghi Nợ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(DebtModel debt) {
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
                'Thanh Toán Khoản Nợ: ${debt.personName}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Dư nợ còn lại: ${CurrencyFormatter.formatVND(debt.remainingAmount)}',
                style: TextStyle(
                  color: debt.type == 'Lend' ? AppTheme.primary : AppTheme.expense,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: debt.type == 'Lend' ? 'Số tiền người đó trả (₫)' : 'Số tiền bạn trả (₫)',
                  hintText: '${debt.remainingAmount.toInt()}',
                  prefixIcon: const Icon(Icons.payment_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              if (wallets.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedWalletId,
                  dropdownColor: const Color(0xFF131B2A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: debt.type == 'Lend' ? 'Nhận tiền vào ví' : 'Trích tiền từ ví trả',
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary),
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
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (amount <= 0 || selectedWalletId == null) return;

                    final success = await context.read<DebtProvider>().makePayment(
                          debtId: debt.id,
                          walletId: selectedWalletId!,
                          amount: amount,
                          note: noteCtrl.text.trim(),
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      context.read<WalletProvider>().fetchWallets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanh toán khoản nợ thành công!')),
                      );
                    }
                  },
                  child: const Text('Xác Nhận Thanh Toán'),
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
        title: const Text('Sổ Nợ & Cho Vay Chuyên Nghiệp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 26),
            onPressed: _showCreateDebtSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Cho Vay (Phải Thu)'),
            Tab(text: 'Tôi Nợ (Phải Trả)'),
          ],
        ),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final summary = provider.summary;
          final allDebts = summary?.debts ?? [];
          final lendDebts = allDebts.where((d) => d.type == 'Lend').toList();
          final borrowDebts = allDebts.where((d) => d.type == 'Borrow').toList();

          return Column(
            children: [
              // Summary Banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.vipCardGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Người khác nợ tôi', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatVND(summary?.totalReceivable ?? 0),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppTheme.borderSubtle),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tôi đang nợ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatVND(summary?.totalPayable ?? 0),
                            style: const TextStyle(
                              color: AppTheme.expense,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDebtList(lendDebts, isLend: true),
                    _buildDebtList(borrowDebts, isLend: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDebtList(List<DebtModel> debts, {required bool isLend}) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLend ? Icons.arrow_outward_rounded : Icons.call_received_rounded,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isLend ? 'Không có khoản cho vay nào' : 'Bạn không nợ ai cả',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final d = debts[index];
        final isSettled = d.status == 'Settled' || d.remainingAmount <= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSettled ? AppTheme.borderSubtle : (isLend ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.expense.withValues(alpha: 0.3)),
            ),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isLend ? AppTheme.primary : AppTheme.expense).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLend ? Icons.arrow_outward_rounded : Icons.call_received_rounded,
                          color: isLend ? AppTheme.primary : AppTheme.expense,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.personName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isSettled ? 'Đã hoàn tất thanh toán' : (d.note ?? 'Chưa thanh toán xong'),
                            style: TextStyle(
                              color: isSettled ? AppTheme.primaryLight : AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted, size: 18),
                    onPressed: () => context.read<DebtProvider>().deleteDebt(d.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gốc: ${CurrencyFormatter.formatVND(d.principalAmount)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  Text(
                    'Còn: ${CurrencyFormatter.formatVND(d.remainingAmount)}',
                    style: TextStyle(
                      color: isSettled ? AppTheme.primaryLight : (isLend ? AppTheme.primary : AppTheme.expense),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (!isSettled) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isLend ? AppTheme.primary : AppTheme.expense,
                      side: BorderSide(color: isLend ? AppTheme.primary : AppTheme.expense),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showPaymentSheet(d),
                    child: Text(isLend ? 'Ghi Nhận Đã Nhận Tiền' : 'Ghi Nhận Đã Trả'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
