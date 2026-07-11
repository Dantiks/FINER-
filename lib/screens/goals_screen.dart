import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          backgroundColor: FinerColors.background,
          appBar: AppBar(
            backgroundColor: FinerColors.background,
            title: const Text('Финансовые цели'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: FinerColors.primary,
                onPressed: () => _showAddGoalDialog(context, finance),
              ),
            ],
          ),
          body: finance.goals.isEmpty
              ? _buildEmpty(context, finance)
              : _buildList(context, finance),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, FinanceProvider finance) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              'Поставьте цель',
              style: TextStyle(
                color: FinerColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Укажите цель — и FINER поможет вам её достичь.',
              textAlign: TextAlign.center,
              style: TextStyle(color: FinerColors.textSecondary, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Создать цель',
              icon: Icons.add_rounded,
              onTap: () => _showAddGoalDialog(context, finance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, FinanceProvider finance) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: finance.goals.length + 1,
      itemBuilder: (_, i) {
        if (i == finance.goals.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            child: GradientButton(
              label: 'Добавить цель',
              icon: Icons.add_rounded,
              onTap: () => _showAddGoalDialog(context, finance),
            ),
          );
        }
        final goal = finance.goals[i];
        final color = Color(int.parse('0xFF${goal.color}'));
        final daysLeft = goal.deadline.difference(DateTime.now()).inDays;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.12), FinerColors.surfaceCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            color: FinerColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'До: ${goal.deadline.day}.${goal.deadline.month}.${goal.deadline.year} • $daysLeft дн.',
                          style: const TextStyle(color: FinerColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: color),
                    onPressed: () => _showAddProgressDialog(context, finance, goal.id),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.savedAmount.toStringAsFixed(0)} ${finance.displayCountry.currencySymbol}',
                    style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'из ${goal.targetAmount.toStringAsFixed(0)} ${finance.displayCountry.currencySymbol}',
                    style: const TextStyle(color: FinerColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: goal.progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(0)}% выполнено',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (goal.progress >= 1.0)
                    const Text('🎉 Цель достигнута!', style: TextStyle(fontSize: 12, color: FinerColors.income)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 80)).slideY(begin: 0.1);
      },
    );
  }

  void _showAddGoalDialog(BuildContext context, FinanceProvider finance) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedEmoji = '🎯';
    DateTime deadline = DateTime.now().add(const Duration(days: 180));

    final emojis = ['🚗', '🏠', '✈️', '💻', '📱', '🎓', '💍', '🎯', '🏋️', '📚'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FinerColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Новая цель',
                style: TextStyle(
                  color: FinerColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Emoji selector
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: emojis.map((e) {
                    final sel = e == selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: sel ? FinerColors.primary.withValues(alpha: 0.15) : FinerColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? FinerColors.primary : Colors.transparent,
                          ),
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: FinerColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Название цели'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: FinerColors.textPrimary),
                decoration: InputDecoration(hintText: 'Целевая сумма (${finance.displayCountry.currencySymbol})'),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Создать',
                onTap: () async {
                  if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                  if (amount == null) return;
                  await finance.addGoal(
                    title: titleCtrl.text,
                    targetAmount: amount,
                    emoji: selectedEmoji,
                    deadline: deadline,
                    color: 'FFD700',
                  );
                  if (context.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context, FinanceProvider finance, String goalId) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FinerColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Пополнить цель', style: TextStyle(color: FinerColors.textPrimary)),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: FinerColors.textPrimary),
          decoration: InputDecoration(hintText: 'Сумма (${finance.displayCountry.currencySymbol})'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: FinerColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
              if (amount != null) {
                await finance.updateGoalProgress(goalId, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
