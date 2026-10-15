import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/report_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _tabIndex = 0; // 0 = Tỷ trọng danh mục, 1 = Xu hướng dòng tiền

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ReportProvider>().fetchCategoryBreakdown();
    context.read<ReportProvider>().fetchMonthlyCashFlow();
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê'),
      ),
      body: Column(
        children: [
          // Switch Tab
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? AppTheme.cardElevated : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _tabIndex == 0 ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4)) : null,
                      ),
                      child: Text(
                        'Cơ cấu chi tiêu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _tabIndex == 0 ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? AppTheme.cardElevated : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _tabIndex == 1 ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4)) : null,
                      ),
                      child: Text(
                        'Dòng tiền 12 tháng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _tabIndex == 1 ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.cardColor,
              onRefresh: () async => _loadData(),
              child: _tabIndex == 0
                  ? _buildCategoryBreakdownTab(reportProv)
                  : _buildCashFlowTab(reportProv),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownTab(ReportProvider reportProv) {
    if (reportProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final list = reportProv.categoryBreakdown;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            const Text('Chưa có dữ liệu chi tiêu trong kỳ này', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    final chartColors = [
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF14B8A6),
      const Color(0xFF6366F1),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Biểu đồ tròn PieChart
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 44,
                  sections: list.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final color = chartColors[i % chartColors.length];

                    return PieChartSectionData(
                      color: color,
                      value: cat.totalAmount,
                      title: '${cat.percentage.toStringAsFixed(0)}%',
                      radius: 52,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Danh sách chi tiết danh mục
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = list[index];
              final color = chartColors[index % chartColors.length];

              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category, color: color, size: 20),
                  ),
                  title: Text(cat.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  subtitle: Text('${cat.transactionCount} giao dịch', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatVND(cat.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                      ),
                      Text(
                        '${cat.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCashFlowTab(ReportProvider reportProv) {
    final list = reportProv.monthlyCashFlow;
    if (list.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu dòng tiền'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.income, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              const Text('Thu nhập', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(width: 20),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.expense, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              const Text('Chi tiêu', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  barGroups: list.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: item.income / 1000000.0,
                          color: AppTheme.income,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: item.expense / 1000000.0,
                          color: AppTheme.expense,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < list.length) {
                            return Text(list[idx].periodLabel, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('(Đơn vị trục: Triệu đồng)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
