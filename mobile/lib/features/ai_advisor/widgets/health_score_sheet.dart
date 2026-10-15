import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ai_advisor_provider.dart';

class HealthScoreSheet extends StatelessWidget {
  const HealthScoreSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiAdvisorProvider>(
      builder: (context, provider, child) {
        final scoreData = provider.healthScore;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: scoreData == null
              ? const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Thanh kéo modal
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.borderSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header VIP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: AppTheme.vipGold, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ĐIỂM SỨC KHỎE TÀI CHÍNH',
                                    style: TextStyle(
                                      color: AppTheme.vipGold.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scoreData.ratingTitle,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldBadgeGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              scoreData.ratingGrade,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Vòng tròn điểm số trung tâm
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.vipCardGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              blurRadius: 24,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${scoreData.score}',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const Text(
                              'trên thang điểm 1.000',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              scoreData.ratingDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13.5,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4 Trụ Cột Đánh Giá Chuẩn Doanh Nghiệp
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chi tiết 4 Trụ Cột Đánh Giá',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildPillarItem(
                        icon: Icons.savings_rounded,
                        name: 'Tích Lũy & Tiết Kiệm',
                        score: scoreData.savingsPillarScore,
                        detail: 'Tỷ lệ tích lũy: ${scoreData.savingsRatePercentage}%',
                        color: AppTheme.primary,
                      ),
                      _buildPillarItem(
                        icon: Icons.pie_chart_rounded,
                        name: 'Kiểm Soát Chi Tiêu',
                        score: scoreData.expensePillarScore,
                        detail: 'Tỷ lệ chi/thu: ${scoreData.expenseToIncomeRatio}%',
                        color: AppTheme.secondary,
                      ),
                      _buildPillarItem(
                        icon: Icons.shield_rounded,
                        name: 'Quỹ Dự Phòng Khẩn Cấp',
                        score: scoreData.runwayPillarScore,
                        detail: 'Bảo chứng an toàn: ${scoreData.emergencyRunwayMonths} tháng',
                        color: AppTheme.info,
                      ),
                      _buildPillarItem(
                        icon: Icons.assignment_turned_in_rounded,
                        name: 'Kỷ Luật Ngân Sách',
                        score: scoreData.budgetPillarScore,
                        detail: 'Tuân thủ kế hoạch: ${scoreData.budgetDisciplinePercentage.toStringAsFixed(0)}%',
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required String name,
    required int score,
    required String detail,
    required Color color,
  }) {
    final ratio = (score / 250).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detail,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '$score/250',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
