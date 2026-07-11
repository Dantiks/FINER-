import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/finance_provider.dart';
import '../services/tax_calculator.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import 'ai_chat_screen.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late final TextEditingController _incomeController;
  KgActivityCategory _kgActivity = KgActivityCategory.otherServices;
  bool _kgCashPayment = true;
  bool _incomeEdited = false;

  static const List<_LegalSection> _legalSections = [
    _LegalSection(
      emoji: '⚖️',
      title: 'Юридические консультации',
      subtitle: 'Базовые ответы на правовые вопросы',
      color: FinerColors.primary,
      items: [
        _LegalItem('Права потребителей', 'Возврат товара, гарантия, защита прав', Icons.shopping_bag_outlined),
        _LegalItem('Трудовые права', 'Оплата труда, увольнение, отпуск', Icons.work_outline_rounded),
        _LegalItem('Жилищные вопросы', 'Аренда, ЖКХ, права нанимателя', Icons.home_outlined),
        _LegalItem('Банки и кредиты', 'Кредитный договор, штрафы, ГЭСВ', Icons.account_balance_outlined),
      ],
    ),
  ];

  static const _LegalSection _kzOmbudsmanSection = _LegalSection(
    emoji: '🛡️',
    title: 'Омбудсмен',
    subtitle: 'Защита ваших финансовых прав в Казахстане',
    color: FinerColors.income,
    items: [
      _LegalItem('Финансовый омбудсмен', '+7 727 237-59-76', Icons.phone_outlined),
      _LegalItem('КГД МФ РК', 'Налоговые споры', Icons.gavel_rounded),
      _LegalItem('АРРФР', 'Регулятор финансового рынка', Icons.business_outlined),
      _LegalItem('Алгоритм действий', 'Шаги при нарушении ваших прав', Icons.list_alt_rounded),
    ],
  );

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  double _resolveIncome(FinanceProvider finance) {
    if (_incomeEdited) {
      return double.tryParse(_incomeController.text.replaceAll(',', '.')) ?? 0;
    }
    return finance.currentMonthIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        final country = finance.displayCountry;
        final income = _resolveIncome(finance);
        final estimate = estimateTax(
          country: country,
          income: income,
          kgActivity: _kgActivity,
          kgCashPayment: _kgCashPayment,
        );

        if (!_incomeEdited) {
          // Keep the field showing the live current-month income until the
          // user starts typing their own override.
          final text = income > 0 ? income.toStringAsFixed(0) : '';
          if (_incomeController.text != text) _incomeController.text = text;
        }

        return Scaffold(
          backgroundColor: FinerColors.background,
          appBar: AppBar(
            backgroundColor: FinerColors.background,
            title: const Text('Право и налоги'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                ),
                icon: const Icon(Icons.smart_toy_rounded, color: FinerColors.primary, size: 18),
                label: const Text('AI', style: TextStyle(color: FinerColors.primary)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildTaxCalculator(country, income, estimate),
              const SizedBox(height: 24),

              // Banner
              GlassCard(
                gradient: LinearGradient(
                  colors: FinerColors.primaryGradient.map((c) => c.withValues(alpha: 0.15)).toList(),
                ),
                borderColor: FinerColors.primary.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Задайте любой правовой вопрос нашему AI. Это базовые консультации — для сложных ситуаций обратитесь к юристу.',
                        style: TextStyle(
                          color: FinerColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              ..._legalSections.asMap().entries.map((e) => _buildSection(e.value, e.key)),

              if (country == AppCountry.kz)
                _buildSection(_kzOmbudsmanSection, _legalSections.length)
              else
                _buildComingSoonNote(),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaxCalculator(AppCountry country, double income, TaxEstimate estimate) {
    final symbol = country.currencySymbol;
    final fmt = NumberFormat.decimalPattern('ru');

    return GlassCard(
      borderColor: FinerColors.warning.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧾', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Налоговый калькулятор · ${country.displayName}',
                      style: const TextStyle(
                        color: FinerColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      estimate.regimeName,
                      style: const TextStyle(color: FinerColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: FinerColors.textPrimary),
            onChanged: (_) => setState(() => _incomeEdited = true),
            decoration: InputDecoration(
              labelText: 'Доход за месяц ($symbol)',
              prefixIcon: const Icon(Icons.attach_money_rounded, color: FinerColors.textHint, size: 18),
            ),
          ),
          if (country == AppCountry.kg) ...[
            const SizedBox(height: 12),
            _buildKgActivityPicker(),
            const SizedBox(height: 10),
            _buildKgPaymentToggle(),
          ],
          const SizedBox(height: 16),
          if (income <= 0)
            const Text(
              'Введите доход, чтобы увидеть расчёт налога.',
              style: TextStyle(color: FinerColors.textSecondary, fontSize: 13),
            )
          else ...[
            ...estimate.lines.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.label,
                              style: const TextStyle(
                                color: FinerColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              line.note,
                              style: const TextStyle(color: FinerColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${fmt.format(line.amount)} $symbol',
                        style: const TextStyle(
                          color: FinerColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(color: FinerColors.textHint, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого налог',
                  style: TextStyle(color: FinerColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${fmt.format(estimate.totalTax)} $symbol',
                  style: const TextStyle(color: FinerColors.warning, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Останется на руках',
                  style: TextStyle(color: FinerColors.textSecondary, fontSize: 13),
                ),
                Text(
                  '${fmt.format(estimate.netIncome)} $symbol',
                  style: const TextStyle(color: FinerColors.income, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (estimate.disclaimer != null) ...[
              const SizedBox(height: 12),
              Text(
                estimate.disclaimer!,
                style: const TextStyle(color: FinerColors.textHint, fontSize: 11, height: 1.4),
              ),
            ],
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildKgActivityPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: KgActivityCategory.values.map((cat) {
        final selected = cat == _kgActivity;
        return GestureDetector(
          onTap: () => setState(() => _kgActivity = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? FinerColors.warning.withValues(alpha: 0.18) : FinerColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? FinerColors.warning : FinerColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              cat.label,
              style: TextStyle(
                color: selected ? FinerColors.textPrimary : FinerColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKgPaymentToggle() {
    if (_kgActivity == KgActivityCategory.catering) return const SizedBox.shrink();
    return Row(
      children: [
        const Text('Оплата:', style: TextStyle(color: FinerColors.textSecondary, fontSize: 12)),
        const SizedBox(width: 10),
        _paymentChip('Наличные', true),
        const SizedBox(width: 8),
        _paymentChip('Безнал', false),
      ],
    );
  }

  Widget _paymentChip(String label, bool cash) {
    final selected = _kgCashPayment == cash;
    return GestureDetector(
      onTap: () => setState(() => _kgCashPayment = cash),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? FinerColors.primary.withValues(alpha: 0.18) : FinerColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? FinerColors.primary : FinerColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? FinerColors.textPrimary : FinerColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonNote() {
    return GlassCard(
      child: const Row(
        children: [
          Text('🛠️', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Раздел «Омбудсмен» для Кыргызстана в разработке. Пока пользуйтесь AI-чатом для правовых вопросов.',
              style: TextStyle(color: FinerColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSection(_LegalSection section, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(section.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: FinerColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    section.subtitle,
                    style: const TextStyle(
                      color: FinerColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: section.items.asMap().entries.map((itemEntry) {
              final item = itemEntry.value;
              final isLast = itemEntry.key == section.items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: section.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: section.color, size: 20),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: FinerColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: FinerColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FinerColors.textHint,
                      size: 14,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiChatScreen()),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: FinerColors.primary.withValues(alpha: 0.07),
                      indent: 16,
                      endIndent: 16,
                      height: 0,
                    ),
                ],
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LegalSection {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<_LegalItem> items;
  const _LegalSection({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.items,
  });
}

class _LegalItem {
  final String title;
  final String subtitle;
  final IconData icon;
  const _LegalItem(this.title, this.subtitle, this.icon);
}
