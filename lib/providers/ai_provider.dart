import 'package:flutter/foundation.dart';

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
      text: '👋 Привет! Я FINER AI — ваш персональный финансовый ассистент.\n\nЯ помогу вам:\n• 📊 Анализировать расходы\n• 💡 Давать советы по сбережениям\n• 🧾 Консультировать по налогам\n• ⚖️ Отвечать на юридические вопросы\n\nО чём вы хотите узнать?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text, {
    double? balance,
    double? income,
    double? expense,
  }) async {
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final response = _generateResponse(text, balance: balance, income: income, expense: expense);
    _messages.add(ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    _isLoading = false;
    notifyListeners();
  }

  String _generateResponse(String question, {double? balance, double? income, double? expense}) {
    final lower = question.toLowerCase();

    // Finance queries
    if (lower.contains('баланс') || lower.contains('сколько')) {
      if (balance != null) {
        return '💰 Ваш текущий баланс: **${balance.toStringAsFixed(0)} ₸**\n\nДоходы: ${income?.toStringAsFixed(0)} ₸\nРасходы: ${expense?.toStringAsFixed(0)} ₸\n\n${_getFinancialAdvice(balance, income, expense)}';
      }
      return '💰 Добавьте транзакции, и я смогу показать ваш баланс!';
    }

    if (lower.contains('расход') || lower.contains('трат')) {
      return '📊 **Анализ расходов:**\n\nОсновные категории трат:\n• 🏠 Жильё — самая большая статья\n• 🛒 Продукты — 15-20% бюджета\n• 🚗 Транспорт — оптимизируйте\n\n💡 Совет: Используйте правило 50/30/20:\n→ 50% — нужды\n→ 30% — желания\n→ 20% — сбережения';
    }

    if (lower.contains('накопи') || lower.contains('сбереж') || lower.contains('копи')) {
      return '🎯 **Советы по накоплениям:**\n\n1. **Правило 24 часов** — не покупайте сразу, подождите день\n2. **Автоматические переводы** — в день зарплаты откладывайте сначала\n3. **Цель SMART** — конкретная, измеримая, достижимая\n\n💡 Рекомендую откладывать минимум 10-20% от дохода каждый месяц.';
    }

    if (lower.contains('налог') || lower.contains('ипн') || lower.contains('опв')) {
      return '🧾 **Налоги в Казахстане:**\n\n• **ИПН (ИПН)** — 10% с дохода\n• **ОПВ** — 10% пенсионные отчисления\n• **ОСМС** — 2% на мед.страхование\n\n📋 Для фрилансеров:\n→ Патент или ИП\n→ Упрощённая декларация (3%)\n\n⚠️ Дедлайн декларации: 31 марта ежегодно\n\nДля детальной консультации обратитесь в КГД.';
    }

    if (lower.contains('кредит') || lower.contains('займ') || lower.contains('долг')) {
      return '💳 **Советы по кредитам:**\n\n🔴 Признаки опасного долга:\n• Платёж > 40% дохода\n• Несколько кредитов одновременно\n\n✅ Стратегия погашения:\n1. **Лавина** — сначала с высоким %\n2. **Снежный ком** — сначала маленькие\n\n⚖️ Юридически: банк обязан предоставить полный расчёт ГЭСВ.';
    }

    if (lower.contains('право') || lower.contains('закон') || lower.contains('суд') || lower.contains('омбудсмен')) {
      return '⚖️ **Правовая консультация:**\n\nЕсли нарушены ваши права:\n1. Зафиксируйте нарушение (фото, видео)\n2. Направьте письменную претензию\n3. Обратитесь в уполномоченный орган\n4. При необходимости — в суд\n\n📞 Горячая линия потребителей: 1400\n📞 Финансовый омбудсмен: +7 727 237-59-76\n\n⚠️ Это базовая консультация. Для сложных случаев обратитесь к юристу.';
    }

    if (lower.contains('инвест') || lower.contains('вклад') || lower.contains('акци')) {
      return '📈 **Инвестиции в Казахстане:**\n\n🏦 **Депозит** — до 10% годовых (КФГД гарантирует до 20 млн ₸)\n📊 **ИИС на бирже KASE** — акции казахстанских компаний\n🌐 **ETF** — диверсификация через международные фонды\n\n💡 Начните с депозита, затем переходите к более рисковым инструментам.\n\n⚠️ Инвестиции = риски. Не вкладывайте деньги, которые нельзя потерять.';
    }

    // Greetings
    if (lower.contains('привет') || lower.contains('здравствуй') || lower.contains('салам')) {
      return '👋 Привет! Рад помочь!\n\nСпросите меня о:\n• 💰 Вашем балансе и расходах\n• 📈 Инвестициях и сбережениях\n• 🧾 Налогах (ИПН, ОПВ)\n• ⚖️ Правовых вопросах\n• 🎯 Финансовых целях';
    }

    // Default intelligent response
    return '🤔 Интересный вопрос!\n\nЯ специализируюсь на:\n\n💬 **Попробуйте спросить:**\n• "Как мои расходы за месяц?"\n• "Как накопить на машину?"\n• "Какой налог с зарплаты?"\n• "Мои права как потребителя"\n• "Как погасить кредит быстрее?"\n\nЧем конкретнее вопрос — тем точнее ответ! 🎯';
  }

  String _getFinancialAdvice(double? balance, double? income, double? expense) {
    if (balance == null || income == null || expense == null) return '';
    final savingsRate = income > 0 ? (balance / income * 100) : 0;
    if (savingsRate > 30) return '🟢 Отлично! Ваш уровень сбережений выше нормы. Рекомендую инвестировать излишки.';
    if (savingsRate > 15) return '🟡 Хороший результат! Попробуйте довести сбережения до 20-30%.';
    if (expense > income) return '🔴 Внимание! Расходы превышают доходы. Нужно срочно пересмотреть бюджет.';
    return '💡 Попробуйте применить правило 50/30/20 для оптимизации финансов.';
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
