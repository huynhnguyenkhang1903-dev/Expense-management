import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final Dio _dio = ApiClient().dio;

  Future<bool> checkAuthStatus() async {
    final token = await StorageService.getToken();
    if (token == null) return false;

    final userId = await StorageService.getUserId();
    final name = await StorageService.getUserName();
    final email = await StorageService.getUserEmail();

    if (userId != null && name != null && email != null) {
      _currentUser = UserModel(
        id: userId,
        fullName: name,
        email: email,
        defaultCurrency: 'VND',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      await StorageService.saveAuthData(
        token: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['userId'],
        userName: data['fullName'],
        userEmail: data['email'],
      );

      _currentUser = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Đăng nhập không thành công';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'defaultCurrency': 'VND',
        },
      );

      final data = response.data['data'];
      await StorageService.saveAuthData(
        token: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['userId'],
        userName: data['fullName'],
        userEmail: data['email'],
      );

      _currentUser = UserModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Đăng ký không thành công';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuthData();
    _currentUser = null;
    notifyListeners();
  }
}
