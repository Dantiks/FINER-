import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';

import '../models/country.dart';
import '../models/transaction.dart';
import '../widgets/tax_impact_card.dart';
import '../widgets/tax_reminder_banner.dart';
import 'add_transaction_screen.dart';
import 'ai_chat_screen.dart';
import 'legal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          backgroundColor: FinerColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, finance),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),
                    TaxReminderBanner(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LegalScreen()),
                      ),
                    ),
                    _buildBalanceCard(finance),
                    const SizedBox(height: 24),
                    TaxImpactCard(
                      country: finance.displayCountry,
                      monthlyIncome: finance.currentMonthIncome,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LegalScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildQuickStats(finance),
                    const SizedBox(height: 24),
                    _buildAiCard(context),
                    const SizedBox(height: 24),
                    _buildGoalsSection(context, finance),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Последние транзакции',
                      action: 'Все',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    ...finance.transactions.take(5).map(
                      (t) => _buildTransactionTile(t),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFab(context),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, FinanceProvider finance) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Доброе утро'
        : now.hour < 17
            ? 'Добрый день'
            : 'Добрый вечер';

    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: FinerColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting + ' 👋',
                        style: const TextStyle(
                          color: FinerColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'FINER',
                        style: TextStyle(
                          color: FinerColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification bell
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FinerColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: FinerColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: FinerColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(FinanceProvider finance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: FinerColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FinerColors.primary.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Общий баланс',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (finance.hasMultiCurrencyData) ...[
                const SizedBox(width: 8),
                _buildCurrencySwitcher(finance),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      finance.balance >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: Colors.black,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${finance.savingsRate.toStringAsFixed(0)}% сбережений',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Balance
          Text(
            '${NumberFormat.decimalPattern('ru').format(finance.balance.abs())} ${finance.displayCountry.currencySymbol}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          // Income / Expense row
          Row(
            children: [
              _buildBalanceStat(
                label: 'Доходы',
                amount: finance.totalIncome,
                symbol: finance.displayCountry.currencySymbol,
                icon: Icons.arrow_downward_rounded,
                isIncome: true,
              ),
              const SizedBox(width: 1),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 1),
              _buildBalanceStat(
                label: 'Расходы',
                amount: finance.totalExpense,
                symbol: finance.displayCountry.currencySymbol,
                icon: Icons.arrow_upward_rounded,
                isIncome: false,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.15, duration: 500.ms)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildCurrencySwitcher(FinanceProvider finance) {
    return GestureDetector(
      onTap: () => finance.setDisplayCountry(
        finance.displayCountry == AppCountry.kg ? AppCountry.kz : AppCountry.kg,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(finance.displayCountry.flag, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 3),
            const Icon(Icons.swap_horiz_rounded, color: Colors.black, size: 13),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceStat({
    required String label,
    required double amount,
    required String symbol,
    required IconData icon,
    required bool isIncome,
  }) {
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              Text(
                '${NumberFormat.compactCurrency(locale: 'ru', symbol: '', decimalDigits: 0).format(amount)} $symbol',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FinanceProvider finance) {
    final txCount = finance.transactions.length;
    final topCategory = finance.expenseByCategory.entries.isEmpty
        ? 'Нет данных'
        : (finance.expenseByCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Row(
      children: [
        Expanded(
          child: StatChip(
            label: 'Транзакций',
            value: txCount.toString(),
            color: FinerColors.primary,
            icon: Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatChip(
            label: 'Топ категория',
            value: topCategory,
            color: FinerColors.warning,
            icon: Icons.category_rounded,
          ),
        ),
      ],
    )
        .animate()
        .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms)
        .fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildAiCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiChatScreen()),
      ),
      child: GlassCard(
        borderColor: FinerColors.accent.withValues(alpha: 0.3),
        gradient: LinearGradient(
          colors: [
            FinerColors.accent.withValues(alpha: 0.08),
            FinerColors.primary.withValues(alpha: 0.05),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: FinerColors.incomeGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FINER AI',
                    style: TextStyle(
                      color: FinerColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Спросите о финансах, налогах, правах...',
                    style: TextStyle(
                      color: FinerColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: FinerColors.accent,
              size: 16,
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.2, duration: 400.ms, delay: 150.ms)
        .fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildGoalsSection(BuildContext context, FinanceProvider finance) {
    if (finance.goals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Мои цели'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: finance.goals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final goal = finance.goals[i];
              final color = Color(int.parse('0xFF${goal.color}'));
              return Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      goal.title,
                      style: const TextStyle(
                        color: FinerColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: goal.progress.clamp(0.0, 1.0),
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(Transaction t) {
    final catData = TransactionCategory.categories[t.category];
    final color = Color(catData?['color'] ?? 0xFF9090B0);
    final iconCode = catData?['icon'] ?? 0xe25b;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinerColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FinerColors.primary.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          CategoryIcon(
            icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    color: FinerColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${t.category} • ${DateFormat('dd MMM', 'ru').format(t.date)}',
                  style: const TextStyle(
                    color: FinerColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          AmountText(amount: t.amount, country: t.country, isIncome: t.isIncome, fontSize: 15),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: FinerColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FinerColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
      ),
    );
  }
}
