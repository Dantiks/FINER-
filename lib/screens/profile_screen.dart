import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          backgroundColor: FinerColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: FinerColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: FinerColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                            ),
                            child: const Center(
                              child: Text('👤', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Пользователь',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'FINER Premium',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStats(finance),
                    const SizedBox(height: 24),
                    _buildSection('Настройки', [
                      _SettingItem(icon: Icons.notifications_outlined, label: 'Уведомления', color: FinerColors.primary),
                      _SettingItem(icon: Icons.lock_outline_rounded, label: 'Безопасность', color: FinerColors.accent),
                      _SettingItem(icon: Icons.language_rounded, label: 'Язык', color: FinerColors.warning),
                      _SettingItem(icon: Icons.palette_outlined, label: 'Внешний вид', color: const Color(0xFF9C3FE4)),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Поддержка', [
                      _SettingItem(icon: Icons.help_outline_rounded, label: 'Помощь', color: FinerColors.info),
                      _SettingItem(icon: Icons.feedback_outlined, label: 'Обратная связь', color: FinerColors.income),
                      _SettingItem(icon: Icons.privacy_tip_outlined, label: 'Конфиденциальность', color: FinerColors.textSecondary),
                    ]),
                    const SizedBox(height: 20),
                    _buildPremiumBanner(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(FinanceProvider finance) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  finance.transactions.length.toString(),
                  style: const TextStyle(
                    color: FinerColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Транзакций',
                  style: TextStyle(color: FinerColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  finance.goals.length.toString(),
                  style: const TextStyle(
                    color: FinerColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Целей',
                  style: TextStyle(color: FinerColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${finance.savingsRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: FinerColors.income,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Сбережений',
                  style: TextStyle(color: FinerColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSection(String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: FinerColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        color: FinerColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FinerColors.textHint,
                      size: 14,
                    ),
                    onTap: () {},
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
        ),
      ],
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: FinerColors.goldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FINER Premium',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Разблокируйте все функции: AI без ограничений, экспорт, детальная аналитика',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Попробовать',
              style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingItem({required this.icon, required this.label, required this.color});
}
