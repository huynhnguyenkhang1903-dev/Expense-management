import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final int initialType; // 1 = Expense, 2 = Income
  final String? initialAmount;
  final String? initialNote;
  final bool isExpense;

  const AddTransactionScreen({
    super.key,
    this.initialType = 1,
    this.initialAmount,
    this.initialNote,
    this.isExpense = true,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late int _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.isExpense ? 1 : (widget.initialType);
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
    }
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallets = context.read<WalletProvider>().wallets;
      if (wallets.isNotEmpty) {
        setState(() => _selectedWalletId = wallets.first.id);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ví thanh toán'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục thu chi'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    final txProv = context.read<TransactionProvider>();
    final success = await txProv.createTransaction(
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      type: _type,
      amount: amount,
      transactionDate: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (mounted) {
      if (success) {
        context.read<WalletProvider>().fetchWallets();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo giao dịch. Vui lòng thử lại.'),
            backgroundColor: AppTheme.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = context.watch<WalletProvider>().wallets;
    final txProv = context.watch<TransactionProvider>();
    final categories = _type == 1 ? txProv.expenseCategories : txProv.incomeCategories;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_type == 1 ? 'Thêm khoản chi' : 'Thêm khoản thu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Thu / Chi
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = 1;
                        _selectedCategoryId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 1 ? AppTheme.expense : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Khoản chi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _type == 1 ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = 2;
                        _selectedCategoryId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 2 ? AppTheme.income : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Khoản thu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _type == 2 ? Colors.black : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nhập số tiền lớn
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  const Text('SỐ TIỀN', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: _type == 1 ? AppTheme.expense : AppTheme.income,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '0 ₫',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chọn Ví
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: AppTheme.cardColor,
                  value: _selectedWalletId,
                  hint: const Text('Chọn ví nguồn', style: TextStyle(color: AppTheme.textSecondary)),
                  items: wallets.map((w) {
                    return DropdownMenuItem(
                      value: w.id,
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(w.name, style: const TextStyle(color: AppTheme.textPrimary)),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.formatVND(w.currentBalance),
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chọn Ngày
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
                title: Text(
                  CurrencyFormatter.formatDate(_selectedDate),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // Ghi chú
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Thêm ghi chú giao dịch...',
                prefixIcon: Icon(Icons.edit_note, color: AppTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 24),

            // Chọn danh mục
            const Text(
              'Chọn danh mục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const CategoryGridDelegate(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategoryId == cat.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.18)
                          : AppTheme.cardColor,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
                        width: isSelected ? 1.8 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('LƯU GIAO DỊCH'),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const CategoryGridDelegate()
      : super(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        );
}
