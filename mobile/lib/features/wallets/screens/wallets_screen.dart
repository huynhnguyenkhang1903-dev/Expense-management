import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/wallet_provider.dart';
import 'transfer_screen.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWallets();
    });
  }

  void _showAddWalletDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    int selectedType = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.borderSubtle),
          ),
          title: const Text('Thêm ví tài khoản mới', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Tên ví (Ví dụ: MB Bank, MoMo)'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Số dư ban đầu (₫)'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedType,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Loại tài khoản'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Tiền mặt')),
                    DropdownMenuItem(value: 2, child: Text('Tài khoản ngân hàng')),
                    DropdownMenuItem(value: 3, child: Text('Ví điện tử')),
                    DropdownMenuItem(value: 4, child: Text('Thẻ tín dụng')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val ?? 1),
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
                final name = nameController.text.trim();
                final balanceText = balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                final balance = double.tryParse(balanceText) ?? 0.0;

                if (name.isEmpty) return;

                final success = await context.read<WalletProvider>().createWallet(
                  name: name,
                  type: selectedType,
                  initialBalance: balance,
                );

                if (context.mounted && success) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Tạo ví'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProv = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản lý ví & tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Chuyển tiền giữa các ví',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showAddWalletDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: walletProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.cardColor,
              onRefresh: () async => walletProv.fetchWallets(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Tổng số dư card
                  Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF131B2A), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TỔNG TÀI SẢN KHẢ DỤNG',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CurrencyFormatter.formatVND(walletProv.totalBalance),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Danh sách ví của bạn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  ...walletProv.wallets.map((w) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            w.type == 2 ? Icons.account_balance : (w.type == 3 ? Icons.phone_android : Icons.wallet),
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          w.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                        ),
                        subtitle: Text(
                          w.typeName,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatVND(w.currentBalance),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
