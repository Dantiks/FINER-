import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          backgroundColor: FinerColors.background,
          appBar: AppBar(
            title: const Text('Аналитика'),
            backgroundColor: FinerColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildSummaryCards(finance),
                const SizedBox(height: 24),
                _buildPieChart(finance),
                const SizedBox(height: 24),
                _buildBarChart(finance),
                const SizedBox(height: 24),
                _buildInsights(finance),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(FinanceProvider finance) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            gradient: LinearGradient(
              colors: FinerColors.incomeGradient.map((c) => c.withValues(alpha: 0.15)).toList(),
            ),
            borderColor: FinerColors.income.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_downward_rounded, color: FinerColors.income, size: 20),
                const SizedBox(height: 8),
                AmountText(amount: finance.totalIncome, isIncome: true, fontSize: 18, showSign: false),
                const Text('Доходы', style: TextStyle(color: FinerColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            gradient: LinearGradient(
              colors: FinerColors.expenseGradient.map((c) => c.withValues(alpha: 0.15)).toList(),
            ),
            borderColor: FinerColors.expense.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_upward_rounded, color: FinerColors.expense, size: 20),
                const SizedBox(height: 8),
                AmountText(amount: finance.totalExpense, isIncome: false, fontSize: 18, showSign: false),
                const Text('Расходы', style: TextStyle(color: FinerColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPieChart(FinanceProvider finance) {
    final catData = finance.expenseByCategory;
    if (catData.isEmpty) {
      return GlassCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Нет данных для отображения.\nДобавьте расходы.',
              textAlign: TextAlign.center,
              style: TextStyle(color: FinerColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final colors = [
      FinerColors.primary,
      FinerColors.accent,
      FinerColors.warning,
      FinerColors.expense,
      FinerColors.info,
      const Color(0xFF9C3FE4),
      const Color(0xFF00C896),
    ];

    final total = catData.values.fold(0.0, (sum, v) => sum + v);
    final entries = catData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расходы по категориям',
            style: TextStyle(color: FinerColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              Expanded(
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                            } else {
                              _touchedIndex = response.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                      sections: entries.asMap().entries.map((e) {
                        final idx = e.key;
                        final entry = e.value;
                        final isSelected = idx == _touchedIndex;
                        final color = colors[idx % colors.length];
                        return PieChartSectionData(
                          color: color,
                          value: entry.value,
                          title: isSelected ? '${(entry.value / total * 100).toStringAsFixed(0)}%' : '',
                          radius: isSelected ? 65 : 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.take(5).toList().asMap().entries.map((e) {
                  final idx = e.key;
                  final entry = e.value;
                  final color = colors[idx % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: FinerColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildBarChart(FinanceProvider finance) {
    final txList = finance.transactions.where((t) => !t.isIncome).toList();
    if (txList.isEmpty) return const SizedBox.shrink();

    // Group by day of week
    final weekData = List<double>.filled(7, 0);
    const dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    for (final t in txList) {
      final day = t.date.weekday - 1;
      weekData[day] += t.amount;
    }
    final maxVal = weekData.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расходы по дням недели',
            style: TextStyle(color: FinerColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: FinerColors.textHint.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text(
                        dayLabels[val.toInt()],
                        style: const TextStyle(
                          color: FinerColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: weekData.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        gradient: const LinearGradient(
                          colors: FinerColors.primaryGradient,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.2,
                          color: FinerColors.surfaceElevated,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInsights(FinanceProvider finance) {
    final savingsRate = finance.savingsRate;
    String insight;
    Color insightColor;
    IconData insightIcon;

    if (savingsRate > 30) {
      insight = '🎉 Отличный результат! Вы откладываете ${savingsRate.toStringAsFixed(0)}% доходов. Рекомендуем инвестировать излишки.';
      insightColor = FinerColors.income;
      insightIcon = Icons.trending_up_rounded;
    } else if (savingsRate > 10) {
      insight = '💡 Вы в зоне роста! Сбережения: ${savingsRate.toStringAsFixed(0)}%. Попробуйте довести до 20-30%.';
      insightColor = FinerColors.warning;
      insightIcon = Icons.lightbulb_outline_rounded;
    } else {
      insight = '⚠️ Расходы высокие. Сбережений: только ${savingsRate.toStringAsFixed(0)}%. Пересмотрите бюджет.';
      insightColor = FinerColors.expense;
      insightIcon = Icons.warning_amber_rounded;
    }

    return GlassCard(
      borderColor: insightColor.withValues(alpha: 0.3),
      gradient: LinearGradient(
        colors: [insightColor.withValues(alpha: 0.08), FinerColors.surfaceCard],
      ),
      child: Row(
        children: [
          Icon(insightIcon, color: insightColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(color: FinerColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: const TextStyle(color: FinerColors.textSecondary, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}
