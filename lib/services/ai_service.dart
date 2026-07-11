import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'tax_calculator.dart';

/// Real AI chat backed by the Anthropic Messages API, scoped to tax/finance
/// Q&A per FINER_Strategic_Analysis_V2 action item #7 ("AI chat focused on
/// tax answers, not general financial advice").
///
/// SECURITY NOTE — read before shipping to real users:
/// The API key is read at compile time via `--dart-define=ANTHROPIC_API_KEY=...`
/// (see README "AI setup"), which keeps it out of source control, but it is
/// still bundled into the compiled app binary and can be extracted by
/// anyone who decompiles the APK/IPA. That's an acceptable trade-off for
/// local development and demos ONLY. Before any public release / app store
/// submission, replace this with calls to a small backend proxy that holds
/// the key server-side (the user has already agreed this is required).
class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);
  @override
  String toString() => message;
}

const _anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
const _anthropicModel = String.fromEnvironment(
  'ANTHROPIC_MODEL',
  defaultValue: 'claude-haiku-4-5-20251001',
);

class AiChatTurn {
  final String role; // 'user' or 'assistant'
  final String text;
  const AiChatTurn({required this.role, required this.text});
}

String _systemPrompt({
  required AppCountry country,
  double? balance,
  double? income,
  double? expense,
  double? monthlyIncome,
  double? monthlyExpense,
  TaxEstimate? taxEstimate,
}) {
  final buffer = StringBuffer()
    ..writeln(
      'Ты — FINER AI, финансовый и налоговый ассистент внутри приложения '
      'FINER для Кыргызстана и Казахстана. Твоя главная задача — простым '
      'языком объяснять налоги (ИПН/ОПВ/ОСМС/упрощёнка для КZ, единый налог '
      'для KG), помогать планировать расходы и сбережения. Не давай общих '
      'финансовых советов не по теме, если не спросили напрямую.',
    )
    ..writeln(
      'Отвечай кратко (3-6 предложений, используй списки где уместно), на '
      'русском языке, дружелюбно, но по делу. Используй эмодзи умеренно.',
    )
    ..writeln(
      'Всегда явно уточняй, что это базовая консультация, а не официальная '
      'юридическая/налоговая консультация — для сложных или спорных случаев '
      'направляй к бухгалтеру/юристу или в ГНС (KG) / КГД (KZ).',
    )
    ..writeln(
      'ВАЖНО: сама не считай точные суммы налога по ставкам — используй '
      'только готовую цифру из "Расчёт налога за этот месяц" ниже, если она '
      'есть. Она посчитана детерминированным калькулятором приложения, '
      'а не тобой, так надёжнее.',
    )
    ..writeln('Текущая страна пользователя: ${country.displayName} (${country.currencyCode}).');

  if (balance != null && income != null && expense != null) {
    buffer.writeln(
      'Общие данные (за всё время) — баланс: ${balance.toStringAsFixed(0)} '
      '${country.currencySymbol}, доходы: ${income.toStringAsFixed(0)} '
      '${country.currencySymbol}, расходы: ${expense.toStringAsFixed(0)} '
      '${country.currencySymbol}.',
    );
  }
  if (monthlyIncome != null && monthlyExpense != null) {
    buffer.writeln(
      'Данные за текущий календарный месяц — доходы: '
      '${monthlyIncome.toStringAsFixed(0)} ${country.currencySymbol}, расходы: '
      '${monthlyExpense.toStringAsFixed(0)} ${country.currencySymbol}.',
    );
  }
  if (taxEstimate != null && taxEstimate.totalTax > 0) {
    buffer.writeln(
      'Расчёт налога за этот месяц (режим "${taxEstimate.regimeName}"): '
      '${taxEstimate.totalTax.toStringAsFixed(0)} ${country.currencySymbol} '
      '(≈${(taxEstimate.effectiveRate * 100).toStringAsFixed(1)}% от дохода), '
      'на руки останется ${taxEstimate.netIncome.toStringAsFixed(0)} ${country.currencySymbol}.'
      '${taxEstimate.disclaimer != null ? " Уточнение: ${taxEstimate.disclaimer}" : ""}',
    );
  }
  return buffer.toString();
}

/// Sends [userMessage] plus prior [history] to Claude and returns the reply
/// text. Throws [AiServiceException] with a user-safe message on failure
/// (missing key, network error, non-200 response) — callers should catch
/// this and show it directly rather than a raw exception.
Future<String> askFinerAi({
  required String userMessage,
  required List<AiChatTurn> history,
  required AppCountry country,
  double? balance,
  double? income,
  double? expense,
  double? monthlyIncome,
  double? monthlyExpense,
  TaxEstimate? taxEstimate,
}) async {
  if (_anthropicApiKey.isEmpty) {
    throw const AiServiceException(
      '⚠️ AI ещё не настроен: не найден ANTHROPIC_API_KEY.\n\n'
      'Запустите приложение с ключом:\n'
      'flutter run --dart-define=ANTHROPIC_API_KEY=ваш_ключ',
    );
  }

  final messages = [
    ...history.map((t) => {'role': t.role, 'content': t.text}),
    {'role': 'user', 'content': userMessage},
  ];

  http.Response response;
  try {
    response = await http
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': _anthropicApiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': _anthropicModel,
            'max_tokens': 512,
            'system': _systemPrompt(
              country: country,
              balance: balance,
              income: income,
              expense: expense,
              monthlyIncome: monthlyIncome,
              monthlyExpense: monthlyExpense,
              taxEstimate: taxEstimate,
            ),
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    throw const AiServiceException(
      '⚠️ Не удалось связаться с AI. Проверьте интернет-соединение и попробуйте снова.',
    );
  }

  if (response.statusCode != 200) {
    throw AiServiceException(
      '⚠️ AI временно недоступен (код ${response.statusCode}). Попробуйте чуть позже.',
    );
  }

  final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  final content = data['content'] as List<dynamic>?;
  final text = content
      ?.whereType<Map<String, dynamic>>()
      .firstWhere((c) => c['type'] == 'text', orElse: () => const {})['text'] as String?;

  if (text == null || text.isEmpty) {
    throw const AiServiceException('⚠️ AI вернул пустой ответ. Попробуйте переформулировать вопрос.');
  }
  return text;
}
