import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/ai_advisor_model.dart';

class AiAdvisorProvider extends ChangeNotifier {
  FinancialHealthScoreModel? _healthScore;
  List<FinancialInsightModel> _insights = [];
  final List<AiChatMessage> _chatMessages = [];
  bool _isLoading = false;
  bool _isChatLoading = false;
  String? _errorMessage;

  // Chế độ bảo mật riêng tư Private Mode (Ẩn số dư trên màn hình)
  bool _isBalanceMasked = false;

  FinancialHealthScoreModel? get healthScore => _healthScore;
  List<FinancialInsightModel> get insights => _insights;
  List<AiChatMessage> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  bool get isChatLoading => _isChatLoading;
  String? get errorMessage => _errorMessage;
  bool get isBalanceMasked => _isBalanceMasked;

  final Dio _dio = ApiClient().dio;

  void toggleBalanceMask() {
    _isBalanceMasked = !_isBalanceMasked;
    notifyListeners();
  }

  Future<void> fetchHealthScore() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.aiHealthScore);
      if (response.data['data'] != null) {
        _healthScore = FinancialHealthScoreModel.fromJson(response.data['data']);
        _insights = _healthScore!.topInsights;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải chỉ số sức khỏe tài chính';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInsights() async {
    try {
      final response = await _dio.get(ApiConstants.aiInsights);
      if (response.data['data'] != null) {
        final list = (response.data['data'] as List)
            .map((i) => FinancialInsightModel.fromJson(i))
            .toList();
        _insights = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> askAi(String question) async {
    if (question.trim().isEmpty) return;

    _chatMessages.add(AiChatMessage(
      text: question.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isChatLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        ApiConstants.aiChat,
        data: {'question': question.trim()},
      );

      final data = response.data['data'];
      final answer = data['answer'] ?? 'Xin lỗi, tôi chưa thể trả lời câu hỏi này lúc này.';
      final suggestions = (data['suggestedQuestions'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList();

      _chatMessages.add(AiChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: suggestions,
      ));
    } catch (e) {
      _chatMessages.add(AiChatMessage(
        text: 'Không thể kết nối đến Trợ lý Cố vấn AI. Vui lòng thử lại sau giây lát.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  void initializeChatIfEmpty() {
    if (_chatMessages.isEmpty) {
      _chatMessages.add(AiChatMessage(
        text: 'Xin chào! Tôi là **MoneyFlow AI Advisor** — Cố vấn tài chính cá nhân VIP của bạn.\n\nTôi có thể giúp bạn phân tích dòng tiền, kiểm tra điểm sức khỏe tài chính hoặc gợi ý cách chi tiêu thông minh.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: [
          'Tháng này tôi đã chi tiêu bao nhiêu?',
          'Làm thế nào để nâng điểm sức khỏe tài chính?',
          'Tôi có nên mua món đồ đắt tiền ngay bây giờ không?',
        ],
      ));
      notifyListeners();
    }
  }
}
