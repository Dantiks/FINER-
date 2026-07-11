import 'package:flutter/foundation.dart';
import '../models/country.dart';
import '../services/ai_service.dart';
import '../services/tax_calculator.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  AiProvider() {
    _messages.add(ChatMessage(
      text: '👋 Привет! Я FINER AI — ваш персональный налоговый и финансовый ассистент.\n\n'
          'Я помогу вам:\n'
          '• 🧾 Разобраться с налогами (ИПН, ОПВ, ОСМС, единый налог)\n'
          '• 📊 Понять свои расходы и доходы\n'
          '• 💡 Спланировать сбережения\n\n'
          'О чём вы хотите узнать?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(
    String text, {
    required AppCountry country,
    double? balance,
    double? income,
    double? expense,
    double? monthlyIncome,
    double? monthlyExpense,
    TaxEstimate? taxEstimate,
  }) async {
    _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();

    // Send the last few turns as context; Claude doesn't need the full
    // history and this keeps the request small.
    final history = _messages
        .where((m) => m != _messages.last)
        .toList()
        .reversed
        .take(8)
        .toList()
        .reversed
        .map((m) => AiChatTurn(role: m.isUser ? 'user' : 'assistant', text: m.text))
        .toList();

    String reply;
    try {
      reply = await askFinerAi(
        userMessage: text,
        history: history,
        country: country,
        balance: balance,
        income: income,
        expense: expense,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        taxEstimate: taxEstimate,
      );
    } on AiServiceException catch (e) {
      reply = e.message;
    } catch (_) {
      reply = '⚠️ Что-то пошло не так. Попробуйте ещё раз.';
    }

    _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
    _isLoading = false;
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: '👋 История очищена. Чем могу помочь?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
