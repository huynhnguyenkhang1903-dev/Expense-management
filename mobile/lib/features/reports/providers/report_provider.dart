import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  DashboardSummaryModel? _dashboardSummary;
  List<CategoryExpenseModel> _categoryBreakdown = [];
  List<CashFlowModel> _monthlyCashFlow = [];
  bool _isLoading = false;

  DashboardSummaryModel? get dashboardSummary => _dashboardSummary;
  List<CategoryExpenseModel> get categoryBreakdown => _categoryBreakdown;
  List<CashFlowModel> get monthlyCashFlow => _monthlyCashFlow;
  bool get isLoading => _isLoading;

  final Dio _dio = ApiClient().dio;

  Future<void> fetchDashboardSummary() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardReport);
      _dashboardSummary = DashboardSummaryModel.fromJson(response.data['data']);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchCategoryBreakdown({DateTime? fromDate, DateTime? toDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = <String, dynamic>{};
      if (fromDate != null) query['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) query['toDate'] = toDate.toIso8601String();

      final response = await _dio.get(
        ApiConstants.categoryBreakdown,
        queryParameters: query,
      );

      final list = (response.data['data'] as List)
          .map((item) => CategoryExpenseModel.fromJson(item))
          .toList();
      _categoryBreakdown = list;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyCashFlow({int? year}) async {
    final targetYear = year ?? DateTime.now().year;
    try {
      final response = await _dio.get(
        ApiConstants.monthlyCashFlow,
        queryParameters: {'year': targetYear},
      );

      final list = (response.data['data'] as List)
          .map((item) => CashFlowModel.fromJson(item))
          .toList();
      _monthlyCashFlow = list;
      notifyListeners();
    } catch (_) {}
  }
}
