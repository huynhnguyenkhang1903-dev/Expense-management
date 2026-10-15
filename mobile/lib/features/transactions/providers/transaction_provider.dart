import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 1).toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 2).toList();

  final Dio _dio = ApiClient().dio;

  Future<void> fetchCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      final list = (response.data['data'] as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
      _categories = list;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchTransactions({
    String? walletId,
    String? categoryId,
    int? type,
    String? searchTerm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'pageIndex': 1,
        'pageSize': 50,
      };
      if (walletId != null) queryParams['walletId'] = walletId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (type != null) queryParams['type'] = type;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }

      final response = await _dio.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
      );

      final items = (response.data['data']['items'] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList();
      _transactions = items;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Không thể tải giao dịch';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi kết nối';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
    required String walletId,
    required String categoryId,
    required int type,
    required double amount,
    required DateTime transactionDate,
    String? note,
  }) async {
    try {
      await _dio.post(
        ApiConstants.transactions,
        data: {
          'walletId': walletId,
          'categoryId': categoryId,
          'type': type,
          'amount': amount,
          'transactionDate': transactionDate.toIso8601String(),
          'note': note,
        },
      );
      await fetchTransactions();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _dio.delete('${ApiConstants.transactions}/$transactionId');
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
