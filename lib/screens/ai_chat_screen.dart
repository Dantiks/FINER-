import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/finer_theme.dart';
import '../providers/ai_provider.dart';
import '../providers/finance_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickQuestions = [
    '💰 Мой баланс',
    '📊 Анализ расходов',
    '🧾 Подскажи по налогам',
    '⚖️ Мои права',
    '🎯 Как накопить?',
    '📈 Советы по инвестициям',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text, {required FinanceProvider finance, required AiProvider ai}) {
    if (text.trim().isEmpty) return;
    final message = text.trim();
    _controller.clear();
    ai.sendMessage(
      message,
      balance: finance.balance,
      income: finance.totalIncome,
      expense: finance.totalExpense,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AiProvider, FinanceProvider>(
      builder: (context, ai, finance, _) {
        return Scaffold(
          backgroundColor: FinerColors.background,
          appBar: AppBar(
            backgroundColor: FinerColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: FinerColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: FinerColors.incomeGradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINER AI',
                      style: TextStyle(
                        color: FinerColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Онлайн',
                      style: TextStyle(color: FinerColors.income, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: FinerColors.textSecondary),
                onPressed: () => ai.clearHistory(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Quick questions
              if (ai.messages.length <= 1)
                _buildQuickQuestions(ai, finance),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: ai.messages.length + (ai.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == ai.messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(ai.messages[i]);
                  },
                ),
              ),

              // Input
              _buildInputBar(ai, finance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickQuestions(AiProvider ai, FinanceProvider finance) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickQuestions[i], finance: finance, ai: ai),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: FinerColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: FinerColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                _quickQuestions[i],
                style: const TextStyle(
                  color: FinerColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: FinerColors.incomeGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(colors: FinerColors.primaryGradient)
                    : null,
                color: isUser ? null : FinerColors.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: FinerColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : FinerColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: FinerColors.incomeGradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FinerColors.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: FinerColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scaleXY(
                      begin: 0.5,
                      end: 1.0,
                      duration: 600.ms,
                      delay: Duration(milliseconds: i * 200),
                      curve: Curves.easeInOut,
                    );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(AiProvider ai, FinanceProvider finance) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: FinerColors.surface,
        border: Border(
          top: BorderSide(color: FinerColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: FinerColors.surfaceCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: FinerColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: FinerColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Спросите FINER AI...',
                  hintStyle: TextStyle(color: FinerColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (v) => _sendMessage(v, finance: finance, ai: ai),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text, finance: finance, ai: ai),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: FinerColors.primaryGradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FinerColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
