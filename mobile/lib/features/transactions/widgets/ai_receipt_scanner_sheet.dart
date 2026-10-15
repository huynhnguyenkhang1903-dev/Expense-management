import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/add_transaction_screen.dart';

class AiReceiptScannerSheet extends StatefulWidget {
  const AiReceiptScannerSheet({super.key});

  @override
  State<AiReceiptScannerSheet> createState() => _AiReceiptScannerSheetState();
}

class _AiReceiptScannerSheetState extends State<AiReceiptScannerSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isScanning = false;

  final List<Map<String, dynamic>> _sampleReceipts = [
    {
      'title': 'Hóa đơn Highlands Coffee',
      'amount': '89000',
      'category': 'Ăn uống',
      'store': 'Highlands Coffee Vincom',
      'note': 'Cà phê phin sữa đá & bánh ngọt với đồng nghiệp',
    },
    {
      'title': 'Hóa đơn Siêu thị WinMart',
      'amount': '345000',
      'category': 'Mua sắm',
      'store': 'WinMart+ Trần Duy Hưng',
      'note': 'Mua thực phẩm tươi sống & nhu yếu phẩm tuần',
    },
    {
      'title': 'Hóa đơn Xăng dầu Petrolimex',
      'amount': '120000',
      'category': 'Di chuyển & Xăng xe',
      'store': 'Petrolimex Cửa Hàng Số 12',
      'note': 'Đổ đầy bình xăng xe máy',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _processReceipt(Map<String, dynamic> receipt) async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.pop(context); // Close sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          initialAmount: receipt['amount'],
          initialNote: receipt['note'],
          isExpense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldGlowGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.document_scanner_rounded, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Smart OCR Scanner',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tự động đọc số tiền & phân loại hóa đơn thông minh',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Viewfinder Animation
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF090D16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isScanning ? 'Đang trích xuất dữ liệu bằng AI...' : 'Chọn hoặc quét hóa đơn mẫu bên dưới',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Laser scanner line
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Positioned(
                      top: 15 + (_animController.value * 125),
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Gợi ý hóa đơn thực tế
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hóa đơn mẫu mô phỏng OCR AI thực tế:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          ..._sampleReceipts.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  tileColor: AppTheme.cardColor,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 20),
                  ),
                  title: Text(
                    r['title'],
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${r['store']} · ${r['amount']} ₫',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
                  onTap: () => _processReceipt(r),
                ),
              )),
        ],
      ),
    );
  }
}
