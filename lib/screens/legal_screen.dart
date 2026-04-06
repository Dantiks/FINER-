import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import 'ai_chat_screen.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const List<_LegalSection> _sections = [
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
    _LegalSection(
      emoji: '🧾',
      title: 'Налоговая помощь',
      subtitle: 'Налоги в Казахстане простым языком',
      color: Color(0xFFFFB347),
      items: [
        _LegalItem('ИПН', 'Индивидуальный подоходный налог — 10%', Icons.percent_rounded),
        _LegalItem('ОПВ', 'Обязательные пенсионные взносы — 10%', Icons.elderly_rounded),
        _LegalItem('ОСМС', 'Мед.страхование — 2% от дохода', Icons.medical_services_outlined),
        _LegalItem('Декларация 910', 'Упрощённая форма для ИП', Icons.description_outlined),
      ],
    ),
    _LegalSection(
      emoji: '🛡️',
      title: 'Омбудсмен',
      subtitle: 'Защита ваших финансовых прав',
      color: FinerColors.income,
      items: [
        _LegalItem('Финансовый омбудсмен', '+7 727 237-59-76', Icons.phone_outlined),
        _LegalItem('КГД МФ РК', 'Налоговые споры', Icons.gavel_rounded),
        _LegalItem('АРРФР', 'Регулятор финансового рынка', Icons.business_outlined),
        _LegalItem('Алгоритм действий', 'Шаги при нарушении ваших прав', Icons.list_alt_rounded),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinerColors.background,
      appBar: AppBar(
        backgroundColor: FinerColors.background,
        title: const Text('Правовая помощь'),
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

          ..._sections.asMap().entries.map((e) {
            final section = e.value;
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
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: e.key * 100)),
                const SizedBox(height: 20),
              ],
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
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
