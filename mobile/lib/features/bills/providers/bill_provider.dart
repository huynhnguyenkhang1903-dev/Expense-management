import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/bill_model.dart';

class BillProvider extends ChangeNotifier {
  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = ApiClient().dio;

  Future<void> fetchBills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.bills);
      final list = (response.data['data'] as List)
          .map((item) => BillModel.fromJson(item))
          .toList();
      _bills = list;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách hóa đơn định kỳ';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBill({
    required String name,
    required double amount,
    required String categoryId,
    String? walletId,
    required DateTime dueDate,
    String frequency = 'Monthly',
    int remindDaysBefore = 3,
  }) async {
    try {
      await _dio.post(
        ApiConstants.bills,
        data: {
          'name': name,
          'amount': amount,
          'categoryId': categoryId,
          'walletId': walletId,
          'dueDate': dueDate.toIso8601String(),
          'frequency': frequency,
          'remindDaysBefore': remindDaysBefore,
        },
      );
      await fetchBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> payBill({
    required String billId,
    required String walletId,
    double? amount,
    String? note,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.bills}/$billId/pay',
        data: {
          'walletId': walletId,
          'amount': amount,
          'note': note,
        },
      );
      await fetchBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBill(String billId) async {
    try {
      await _dio.delete('${ApiConstants.bills}/$billId');
      _bills.removeWhere((b) => b.id == billId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
