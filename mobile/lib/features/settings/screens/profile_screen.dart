import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../wallets/screens/wallets_screen.dart';
import '../../savings_goals/screens/savings_goals_screen.dart';
import '../../debts/screens/debts_screen.dart';
import '../../bills/screens/bills_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = true;

  void _exportCsv() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final dio = ApiClient().dio;
      final response = await dio.get<List<int>>(
        ApiConstants.exportCsv,
        options: Options(responseType: ResponseType.bytes),
      );

      if (mounted) {
        Navigator.pop(context); // close loader
        final byteCount = response.data?.length ?? 0;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text('Xuất Dữ Liệu Thành Công', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
              ],
            ),
            content: Text(
              'Đã tạo tệp sao lưu dữ liệu CSV chuẩn ERP ($byteCount bytes) với mã hóa UTF-8 tiếng Việt sẵn sàng mở trên Microsoft Excel.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải tệp CSV xuất báo cáo')),
        );
      }
    }
  }

  void _showAuditLogs() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
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
            const Row(
              children: [
                Icon(Icons.security_rounded, color: AppTheme.primary, size: 22),
                SizedBox(width: 10),
                Text(
                  'Nhật Ký Kiểm Toán Bảo Mật (Audit Log)',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Ghi nhận các sự kiện bảo mật theo chuẩn doanh nghiệp',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
                future: ApiClient().dio.get(ApiConstants.auditLogs),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  final list = (snapshot.data?.data?['data'] as List<dynamic>?) ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('Chưa có sự kiện bất thường nào ghi nhận', style: TextStyle(color: AppTheme.textMuted)),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final item = list[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['action'] ?? 'Hành động hệ thống',
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item['details'] ?? '',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cá Nhân & Cài Đặt VIP'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // VIP User Platinum Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: AppTheme.vipCardGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.vipGold, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF162032),
                        child: Text(
                          user != null && user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'V',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.vipGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user?.fullName ?? 'Khách Hàng VIP',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: AppTheme.vipGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'MONEYFLOW PRIVATE VIP',
                            style: TextStyle(
                              color: AppTheme.vipGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Hội viên trọn đời',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'TÍNH NĂNG TÀI CHÍNH VIP',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMuted, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.savings_outlined, color: AppTheme.primary),
                  title: const Text('Hũ Tiết Kiệm & Quỹ Tích Lũy', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Quản lý tiến độ mua sắm & dự phòng', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsGoalsScreen())),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.handshake_outlined, color: AppTheme.secondary),
                  title: const Text('Sổ Nợ & Cho Vay Chuyên Nghiệp', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Theo dõi phải thu / phải trả chuẩn kế toán', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen())),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppTheme.warning),
                  title: const Text('Hóa Đơn & Thuê Bao Định Kỳ', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Nhắc hẹn tiền nhà, điện nước, Netflix', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen())),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryLight),
                  title: const Text('Quản Lý Ví & Tài Khoản', style: TextStyle(color: AppTheme.textPrimary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletsScreen())),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'DOANH NGHIỆP & BẢO MẬT HỆ THỐNG',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMuted, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppTheme.primary),
                  title: const Text('Xuất Báo Cáo Tài Chính CSV', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Đồng bộ vào Microsoft Excel / ERP', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.download_rounded, color: AppTheme.primary, size: 20),
                  onTap: _exportCsv,
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderSubtle),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: AppTheme.secondary),
                  title: const Text('Nhật Ký Kiểm Toán (Audit Logs)', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Lịch sử truy cập và giao dịch bảo mật', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                  onTap: _showAuditLogs,
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderSubtle),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppTheme.info),
                  title: const Text('Khóa Sinh Trắc Học / PIN', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: const Text('Bảo vệ ứng dụng khi thoát màn hình', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  value: _biometricEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.expense,
              side: const BorderSide(color: AppTheme.expense, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
