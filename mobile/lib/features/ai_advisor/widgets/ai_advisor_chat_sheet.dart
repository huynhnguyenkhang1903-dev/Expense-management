import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ai_advisor_provider.dart';

class AiAdvisorChatSheet extends StatefulWidget {
  const AiAdvisorChatSheet({super.key});

  @override
  State<AiAdvisorChatSheet> createState() => _AiAdvisorChatSheetState();
}

class _AiAdvisorChatSheetState extends State<AiAdvisorChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiAdvisorProvider>().initializeChatIfEmpty();
    });
  }

  void _sendMessage([String? textToSend]) {
    final text = textToSend ?? _controller.text;
    if (text.trim().isEmpty) return;
    context.read<AiAdvisorProvider>().askAi(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiAdvisorProvider>(
      builder: (context, provider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0B0F19),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Thanh kéo & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.borderSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.emeraldGlowGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MoneyFlow AI Advisor',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Cố vấn tài chính cá nhân VIP',
                                style: TextStyle(color: AppTheme.primary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.borderSubtle, height: 1),

              // Chat Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.chatMessages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              if (provider.isChatLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'AI đang phân tích dữ liệu tài chính của bạn...',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // Input Bar
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF131B2A),
                  border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Hỏi trợ lý AI về tài chính...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFF090D16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black),
                        onPressed: () => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(dynamic msg) {
    final isUser = msg.isUser as bool;
    final text = msg.text as String;
    final suggestions = msg.suggestions as List<String>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primary.withValues(alpha: 0.15) : const Color(0xFF162032),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: Border.all(
                      color: isUser ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser ? AppTheme.primaryLight : AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (suggestions != null && suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions.map((s) {
                return InkWell(
                  onTap: () => _sendMessage(s),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          s,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
