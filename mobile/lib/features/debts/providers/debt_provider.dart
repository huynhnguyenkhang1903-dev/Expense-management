import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/debt_model.dart';

class DebtProvider extends ChangeNotifier {
  DebtSummaryModel? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  DebtSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = ApiClient().dio;

  Future<void> fetchDebtsSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.debts);
      if (response.data['data'] != null) {
        _summary = DebtSummaryModel.fromJson(response.data['data']);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải sổ nợ & cho vay';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDebt({
    required String personName,
    required String type, // Borrow hoặc Lend
    required double principalAmount,
    DateTime? dueDate,
    String? note,
    String? walletId,
  }) async {
    try {
      await _dio.post(
        ApiConstants.debts,
        data: {
          'personName': personName,
          'type': type,
          'principalAmount': principalAmount,
          'dueDate': dueDate?.toIso8601String(),
          'note': note,
          'walletId': walletId,
        },
      );
      await fetchDebtsSummary();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> makePayment({
    required String debtId,
    required String walletId,
    required double amount,
    String? note,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.debts}/$debtId/payments',
        data: {
          'walletId': walletId,
          'amount': amount,
          'note': note,
        },
      );
      await fetchDebtsSummary();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDebt(String debtId) async {
    try {
      await _dio.delete('${ApiConstants.debts}/$debtId');
      await fetchDebtsSummary();
      return true;
    } catch (e) {
      return false;
    }
  }
}
