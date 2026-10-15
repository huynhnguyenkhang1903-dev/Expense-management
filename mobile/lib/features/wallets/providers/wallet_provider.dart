import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBalance => _wallets
      .where((w) => !w.isExcludedFromTotal)
      .fold(0.0, (sum, w) => sum + w.currentBalance);

  final Dio _dio = ApiClient().dio;

  Future<void> fetchWallets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.wallets);
      final list = (response.data['data'] as List)
          .map((item) => WalletModel.fromJson(item))
          .toList();
      _wallets = list;
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Không thể tải danh sách ví';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi kết nối';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createWallet({
    required String name,
    required int type,
    required double initialBalance,
    String colorCode = '#3B82F6',
    String iconName = 'wallet',
  }) async {
    try {
      await _dio.post(
        ApiConstants.wallets,
        data: {
          'name': name,
          'type': type,
          'initialBalance': initialBalance,
          'currency': 'VND',
          'colorCode': colorCode,
          'iconName': iconName,
        },
      );
      await fetchWallets();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transferMoney({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0.0,
    String? note,
  }) async {
    try {
      await _dio.post(
        ApiConstants.transfer,
        data: {
          'fromWalletId': fromWalletId,
          'toWalletId': toWalletId,
          'amount': amount,
          'fee': fee,
          'note': note,
        },
      );
      await fetchWallets();
      return true;
    } catch (e) {
      return false;
    }
  }
}
