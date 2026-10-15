import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalProvider extends ChangeNotifier {
  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = ApiClient().dio;

  Future<void> fetchGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.savingsGoals);
      final list = (response.data['data'] as List)
          .map((item) => SavingsGoalModel.fromJson(item))
          .toList();
      _goals = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách mục tiêu tích lũy';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGoal({
    required String name,
    required double targetAmount,
    double initialAmount = 0,
    String? walletId,
    DateTime? targetDate,
    String color = '#10B981',
  }) async {
    try {
      await _dio.post(
        ApiConstants.savingsGoals,
        data: {
          'name': name,
          'targetAmount': targetAmount,
          'initialAmount': initialAmount,
          'walletId': walletId,
          'targetDate': targetDate?.toIso8601String(),
          'color': color,
        },
      );
      await fetchGoals();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> depositToGoal({
    required String goalId,
    required String walletId,
    required double amount,
    String? note,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.savingsGoals}/$goalId/deposit',
        data: {
          'walletId': walletId,
          'amount': amount,
          'note': note,
        },
      );
      await fetchGoals();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _dio.delete('${ApiConstants.savingsGoals}/$goalId');
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
