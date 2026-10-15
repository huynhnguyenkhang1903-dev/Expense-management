import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/wallet_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? _fromWalletId;
  String? _toWalletId;
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallets = context.read<WalletProvider>().wallets;
      if (wallets.length >= 2) {
        setState(() {
          _fromWalletId = wallets[0].id;
          _toWalletId = wallets[1].id;
        });
      } else if (wallets.isNotEmpty) {
        setState(() => _fromWalletId = wallets[0].id);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền cần chuyển'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ ví chuyển và ví nhận'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    if (_fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ví nguồn và ví nhận không được trùng nhau'),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    final feeText = _feeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final fee = double.tryParse(feeText) ?? 0.0;

    final success = await context.read<WalletProvider>().transferMoney(
      fromWalletId: _fromWalletId!,
      toWalletId: _toWalletId!,
      amount: amount,
      fee: fee,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chuyển tiền thành công!'),
            backgroundColor: AppTheme.primary,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chuyển tiền thất bại. Vui lòng kiểm tra lại số dư.'),
            backgroundColor: AppTheme.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = context.watch<WalletProvider>().wallets;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Chuyển tiền giữa các ví'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ví chuyển (From)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chuyển từ ví (Nguồn)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      value: _fromWalletId,
                      items: wallets.map((w) {
                        return DropdownMenuItem(
                          value: w.id,
                          child: Row(
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              const Spacer(),
                              Text(
                                CurrencyFormatter.formatVND(w.currentBalance),
                                style: const TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _fromWalletId = val),
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Icon(Icons.arrow_downward, color: AppTheme.primary, size: 20),
                ),
              ),
            ),

            // Ví nhận (To)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Đến ví (Đích)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      value: _toWalletId,
                      items: wallets.map((w) {
                        return DropdownMenuItem(
                          value: w.id,
                          child: Row(
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              const Spacer(),
                              Text(
                                CurrencyFormatter.formatVND(w.currentBalance),
                                style: const TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _toWalletId = val),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Số tiền
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  const Text('SỐ TIỀN CHUYỂN', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1.0)),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '0 ₫',
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Phí chuyển tiền
            TextField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Phí giao dịch (nếu có)',
                prefixIcon: Icon(Icons.money_off, color: AppTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 14),

            // Ghi chú
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Ghi chú chuyển tiền',
                prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('XÁC NHẬN CHUYỂN TIỀN'),
            ),
          ],
        ),
      ),
    );
  }
}
