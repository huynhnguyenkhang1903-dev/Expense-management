import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = ApiClient().dio;

  Future<void> fetchBudgets({int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    try {
      final response = await _dio.get(
        ApiConstants.budgets,
        queryParameters: {'month': targetMonth, 'year': targetYear},
      );

      final list = (response.data['data'] as List)
          .map((item) => BudgetModel.fromJson(item))
          .toList();
      _budgets = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải ngân sách';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrUpdateBudget({
    String? categoryId,
    required double limitAmount,
    required int month,
    required int year,
  }) async {
    try {
      await _dio.post(
        ApiConstants.budgets,
        data: {
          'categoryId': categoryId,
          'limitAmount': limitAmount,
          'period': 1, // Monthly
          'month': month,
          'year': year,
        },
      );
      await fetchBudgets(month: month, year: year);
      return true;
    } catch (e) {
      return false;
    }
  }
}
