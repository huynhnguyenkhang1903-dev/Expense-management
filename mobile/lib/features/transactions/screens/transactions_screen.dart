import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int? _selectedType; // null = all, 1 = expense, 2 = income
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  void _fetchTransactions() {
    context.read<TransactionProvider>().fetchTransactions(
      type: _selectedType,
      searchTerm: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProv = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          _fetchTransactions();
        },
      ),
      body: Column(
        children: [
          // Tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo ghi chú...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _fetchTransactions();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _fetchTransactions(),
            ),
          ),

          // Bộ lọc loại giao dịch (Filter Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _selectedType == null,
                  backgroundColor: AppTheme.cardColor,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: _selectedType == null ? AppTheme.primary : AppTheme.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedType == null ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: _selectedType == null ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = null);
                      _fetchTransactions();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Khoản chi'),
                  selected: _selectedType == 1,
                  backgroundColor: AppTheme.cardColor,
                  selectedColor: AppTheme.expense.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: _selectedType == 1 ? AppTheme.expense : AppTheme.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedType == 1 ? AppTheme.expense : AppTheme.textSecondary,
                    fontWeight: _selectedType == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? 1 : null);
                    _fetchTransactions();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Khoản thu'),
                  selected: _selectedType == 2,
                  backgroundColor: AppTheme.cardColor,
                  selectedColor: AppTheme.income.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: _selectedType == 2 ? AppTheme.income : AppTheme.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedType == 2 ? AppTheme.income : AppTheme.textSecondary,
                    fontWeight: _selectedType == 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? 2 : null);
                    _fetchTransactions();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách giao dịch
          Expanded(
            child: txProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : txProv.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade700),
                            const SizedBox(height: 12),
                            const Text(
                              'Không tìm thấy giao dịch nào',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: AppTheme.cardColor,
                        onRefresh: () async => _fetchTransactions(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: txProv.transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tx = txProv.transactions[index];
                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.expense,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppTheme.cardColor,
                                    title: const Text('Xác nhận xóa', style: TextStyle(color: AppTheme.textPrimary)),
                                    content: const Text(
                                      'Bạn có chắc muốn xóa giao dịch này? Số dư ví sẽ được tự động hoàn lại.',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Xóa', style: TextStyle(color: AppTheme.expense, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                txProv.deleteTransaction(tx.id);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (tx.isExpense ? AppTheme.expense : AppTheme.income).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      tx.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: tx.isExpense ? AppTheme.expense : AppTheme.income,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    tx.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tx.walletName} • ${CurrencyFormatter.formatDate(tx.transactionDate)}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                      if (tx.note != null && tx.note!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          tx.note!,
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Text(
                                    '${tx.isExpense ? '-' : '+'}${CurrencyFormatter.formatVND(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: tx.isExpense ? AppTheme.expense : AppTheme.income,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
