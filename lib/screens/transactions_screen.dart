import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'Все';
  final List<String> _filters = ['Все', 'Доходы', 'Расходы'];

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        var txList = finance.transactions;
        if (_filter == 'Доходы') txList = txList.where((t) => t.isIncome).toList();
        if (_filter == 'Расходы') txList = txList.where((t) => !t.isIncome).toList();

        return Scaffold(
          backgroundColor: FinerColors.background,
          appBar: AppBar(
            backgroundColor: FinerColors.background,
            title: const Text('Транзакции'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: txList.isEmpty
                    ? _buildEmpty()
                    : _buildList(txList, finance),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _filters.map((f) {
          final isSelected = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: FinerColors.primaryGradient)
                      : null,
                  color: isSelected ? null : FinerColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : FinerColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? Colors.black : FinerColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💸', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Нет транзакций',
            style: TextStyle(
              color: FinerColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте первую транзакцию',
            style: TextStyle(color: FinerColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Добавить',
            icon: Icons.add_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Transaction> txList, FinanceProvider finance) {
    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final t in txList) {
      final key = DateFormat('d MMMM yyyy', 'ru').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (_, groupIdx) {
        final date = grouped.keys.elementAt(groupIdx);
        final items = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: const TextStyle(
                  color: FinerColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...items.asMap().entries.map((e) {
              final t = e.value;
              final catData = TransactionCategory.categories[t.category];
              final color = Color(catData?['color'] ?? 0xFF9090B0);
              final iconCode = catData?['icon'] ?? 0xe25b;

              return Dismissible(
                key: Key(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: FinerColors.expense.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: FinerColors.expense),
                ),
                onDismissed: (_) => finance.deleteTransaction(t.id),
                child: Container(
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
                              '${t.category} ${t.country.flag}',
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
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: Duration(milliseconds: e.key * 50))
                    .slideX(begin: 0.05),
              );
            }),
          ],
        );
      },
    );
  }
}
