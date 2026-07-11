import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/country.dart';
import '../services/tax_calculator.dart';
import '../theme/finer_theme.dart';

/// The home-screen "spend → future tax impact" widget — the product's core
/// differentiator per FINER_Strategic_Analysis_V2 (section 5.2: "the link
/// between a spend and its future tax impact — something no competitor
/// has"). Shows what the user's income logged this month means for their
/// upcoming tax bill, live, without leaving the home screen.
class TaxImpactCard extends StatelessWidget {
  final AppCountry country;
  final double monthlyIncome;
  final VoidCallback onTap;

  const TaxImpactCard({
    super.key,
    required this.country,
    required this.monthlyIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estimate = estimateTax(country: country, income: monthlyIncome);
    final symbol = country.currencySymbol;
    final fmt = NumberFormat.decimalPattern('ru');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FinerColors.warning.withValues(alpha: 0.14),
              FinerColors.surfaceCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: FinerColors.warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: FinerColors.warning.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: FinerColors.warning, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Налоги с дохода за этот месяц',
                    style: TextStyle(
                      color: FinerColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: FinerColors.textHint, size: 14),
              ],
            ),
            const SizedBox(height: 16),
            if (monthlyIncome <= 0)
              Text(
                'Добавьте доход за этот месяц — покажем, сколько примерно уйдёт на налоги по режиму «${estimate.regimeName}» и сколько останется на руках.',
                style: const TextStyle(color: FinerColors.textSecondary, fontSize: 13, height: 1.5),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${fmt.format(estimate.totalTax)} $symbol',
                    style: const TextStyle(
                      color: FinerColors.warning,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '≈ ${(estimate.effectiveRate * 100).toStringAsFixed(1)}% от дохода',
                      style: const TextStyle(color: FinerColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Доход ${fmt.format(monthlyIncome)} $symbol → на руки останется ${fmt.format(estimate.netIncome)} $symbol после налогов (${estimate.regimeName}).',
                style: const TextStyle(color: FinerColors.textSecondary, fontSize: 12.5, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
