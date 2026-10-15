import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../models/bill_model.dart';
import '../providers/bill_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().fetchBills();
      context.read<TransactionProvider>().fetchCategories();
      context.read<WalletProvider>().fetchWallets();
    });
  }

  void _showCreateBillSheet() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final categories = context.read<TransactionProvider>().categories;
    final wallets = context.read<WalletProvider>().wallets;

    String? selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    String? selectedWalletId = wallets.isNotEmpty ? wallets.first.id : null;
    String selectedFrequency = 'Monthly';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

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
                'Thiết Lập Hóa Đơn Định Kỳ Mới',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tiền nhà, điện nước, mạng Internet hoặc gói thuê bao Netflix, Spotify',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Tên dịch vụ / hóa đơn',
                  hintText: 'Ví dụ: Tiền mạng FPT, Netflix Premium...',
                  prefixIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số tiền định kỳ (₫)',
                  hintText: '260000',
                  prefixIcon: Icon(Icons.monetization_on_rounded, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              if (categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  dropdownColor: const Color(0xFF131B2A),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Danh mục chi phí',
                    prefixIcon: Icon(Icons.category_rounded, color: AppTheme.primary),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedCategoryId = val),
                ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedFrequency,
                dropdownColor: const Color(0xFF131B2A),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Chu kỳ lặp lại',
                  prefixIcon: Icon(Icons.repeat_rounded, color: AppTheme.primary),
                ),
                items: const [
                  DropdownMenuItem(value: 'Monthly', child: Text('Hàng tháng')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Hàng tuần')),
                  DropdownMenuItem(value: 'Yearly', child: Text('Hàng năm')),
                ],
                onChanged: (val) => setSheetState(() => selectedFrequency = val ?? 'Monthly'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || amount <= 0 || selectedCategoryId == null) return;

                    final success = await context.read<BillProvider>().createBill(
                          name: name,
                          amount: amount,
                          categoryId: selectedCategoryId!,
                          walletId: selectedWalletId,
                          dueDate: selectedDate,
                          frequency: selectedFrequency,
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thiết lập hóa đơn định kỳ thành công!')),
                      );
                    }
                  },
                  child: const Text('Kích Hoạt Theo Dõi Hóa Đơn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaySheet(BillModel bill) {
    final amountCtrl = TextEditingController(text: '${bill.amount.toInt()}');
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
                'Thanh Toán Hóa Đơn: ${bill.name}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hệ thống sẽ tự động trừ ví, ghi nhận chi tiêu và dời kỳ hạn sang tháng kế tiếp',
                style: TextStyle(color: AppTheme.primary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Số tiền thanh toán (₫)',
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
                    labelText: 'Ví thanh toán',
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
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (amount <= 0 || selectedWalletId == null) return;

                    final success = await context.read<BillProvider>().payBill(
                          billId: bill.id,
                          walletId: selectedWalletId!,
                          amount: amount,
                        );

                    if (ctx.mounted && success) {
                      Navigator.pop(ctx);
                      context.read<WalletProvider>().fetchWallets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thanh toán hóa đơn ${bill.name}!')),
                      );
                    }
                  },
                  child: const Text('Xác Nhận Thanh Toán 1-Chạm'),
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
        title: const Text('Hóa Đơn & Thuê Bao Định Kỳ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 26),
            onPressed: _showCreateBillSheet,
          ),
        ],
      ),
      body: Consumer<BillProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (provider.bills.isEmpty) {
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
                      child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Chưa có Hóa Đơn Định Kỳ nào',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thêm tiền trọ, điện nước, mạng Internet hoặc Netflix để không bao giờ quên đóng phí',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Thiết Lập Hóa Đơn Đầu Tiên'),
                      onPressed: _showCreateBillSheet,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.bills.length,
            itemBuilder: (context, index) {
              final bill = provider.bills[index];
              return _buildBillCard(bill);
            },
          );
        },
      ),
    );
  }

  Widget _buildBillCard(BillModel bill) {
    Color tagColor = AppTheme.primary;
    String tagText = 'Còn ${bill.daysRemaining} ngày';

    if (bill.isOverdue) {
      tagColor = AppTheme.expense;
      tagText = 'Quá hạn ${-bill.daysRemaining} ngày';
    } else if (bill.daysRemaining == 0) {
      tagColor = AppTheme.warning;
      tagText = 'Hôm nay đến hạn!';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: bill.isOverdue ? AppTheme.expense.withValues(alpha: 0.5) : AppTheme.borderSubtle,
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_rounded, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bill.categoryName} · ${bill.frequency == 'Monthly' ? 'Hàng tháng' : 'Định kỳ'}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Số tiền định kỳ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatVND(bill.amount),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Thanh Toán'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => _showPaySheet(bill),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
