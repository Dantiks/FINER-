import '../models/country.dart';

/// Tax rate constants for FINER's two markets.
///
/// This is intentionally the ONLY place these numbers live, per the V2
/// strategy report's own action item #12: "review tax logic annually as an
/// operational process, not a one-off" (lesson from the KZ 2026 reform).
/// Every rate below is cited so the next review knows what to re-check.
///
/// Sources checked 2026-07 (see conversation for full citations):
/// - KZ упрощённая декларация rate/threshold: asistent.kz, mybuh.kz (both
///   describe the post-2026-01-01 Tax Code's three СНР regimes)
/// - KG единый налог rates: sti.gov.kg (official State Tax Service),
///   cross-checked against kgaccount.com
///
/// NOT included: KG патент (fixed-sum lookup table by activity/region/
/// revenue tier, not a formula — see docs/tax_calculator_notes if this is
/// ever tackled), and KZ ОПВ/ОСМС (mandatory personal contributions based on
/// a self-declared salary base, not a pure function of income — shown as a
/// fixed informational note instead of a computed number so we don't present
/// false precision).
class TaxRates {
  // --- Kazakhstan: СНР на основе упрощённой декларации (2026 Tax Code) ---
  static const double kzSimplifiedBaseRate = 0.04;
  static const double kzSimplifiedRegionalAdjustment = 0.5; // maslikhats can move it +/-50%
  static const double kzSimplifiedMinRate = kzSimplifiedBaseRate * (1 - kzSimplifiedRegionalAdjustment);
  static const double kzSimplifiedMaxRate = kzSimplifiedBaseRate * (1 + kzSimplifiedRegionalAdjustment);
  static const int kzSimplifiedAnnualThresholdMrp = 600000;

  // --- Kyrgyzstan: единый налог (sti.gov.kg) ---
  static const double kgTradeProductionCash = 0.04;
  static const double kgTradeProductionNonCash = 0.02;
  static const double kgOtherServicesCash = 0.06;
  static const double kgOtherServicesNonCash = 0.04;
  static const double kgCateringFlat = 0.08;
  static const int kgAnnualThresholdSom = 8000000;
}

enum KgActivityCategory {
  tradeOrProduction,
  otherServices,
  catering,
}

extension KgActivityCategoryLabel on KgActivityCategory {
  String get label => switch (this) {
        KgActivityCategory.tradeOrProduction => 'Торговля / производство / переработка',
        KgActivityCategory.otherServices => 'Прочие услуги',
        KgActivityCategory.catering => 'Общепит / сауны / бильярд',
      };
}

class TaxLineItem {
  final String label;
  final double amount;
  final String note;
  const TaxLineItem({required this.label, required this.amount, required this.note});
}

class TaxEstimate {
  final AppCountry country;
  final double income;
  final List<TaxLineItem> lines;
  final String regimeName;
  final String? disclaimer;

  const TaxEstimate({
    required this.country,
    required this.income,
    required this.lines,
    required this.regimeName,
    this.disclaimer,
  });

  double get totalTax => lines.fold(0.0, (sum, l) => sum + l.amount);
  double get netIncome => income - totalTax;
  double get effectiveRate => income > 0 ? totalTax / income : 0;
}

/// Estimates tax owed on [income] for the given [country]. This is the
/// concrete implementation of the report's core differentiator: "spend →
/// future tax impact" (FINER_Strategic_Analysis_V2, section 5.2/10).
///
/// For KG, [kgActivity] and [kgCashPayment] select which единый налог rate
/// applies (they're ignored for KZ). For KZ, only the ИПН-equivalent
/// component is computed — ОПВ/ОСМС are flagged as a separate fixed
/// obligation rather than estimated, see TaxRates doc comment above.
TaxEstimate estimateTax({
  required AppCountry country,
  required double income,
  KgActivityCategory kgActivity = KgActivityCategory.otherServices,
  bool kgCashPayment = true,
}) {
  if (income <= 0) {
    return TaxEstimate(
      country: country,
      income: 0,
      lines: const [],
      regimeName: country == AppCountry.kz ? 'Упрощённая декларация' : 'Единый налог',
    );
  }

  if (country == AppCountry.kz) {
    final tax = income * TaxRates.kzSimplifiedBaseRate;
    return TaxEstimate(
      country: country,
      income: income,
      regimeName: 'Упрощённая декларация (СНР)',
      lines: [
        TaxLineItem(
          label: 'ИПН по упрощёнке',
          amount: tax,
          note: '4% от дохода (маслихат региона может скорректировать до '
              '${(TaxRates.kzSimplifiedMinRate * 100).toStringAsFixed(0)}–'
              '${(TaxRates.kzSimplifiedMaxRate * 100).toStringAsFixed(0)}%)',
        ),
      ],
      disclaimer: 'Не включает ОПВ (10%) и ОСМС — это отдельные обязательные '
          'взносы на основе самостоятельно заявленной базы дохода (от 1 до '
          '50 МЗП), их нужно рассчитать отдельно в ГНС/ЕНПФ.',
    );
  }

  // Kyrgyzstan — единый налог, rate depends on activity + payment method.
  double rate;
  switch (kgActivity) {
    case KgActivityCategory.tradeOrProduction:
      rate = kgCashPayment ? TaxRates.kgTradeProductionCash : TaxRates.kgTradeProductionNonCash;
      break;
    case KgActivityCategory.otherServices:
      rate = kgCashPayment ? TaxRates.kgOtherServicesCash : TaxRates.kgOtherServicesNonCash;
      break;
    case KgActivityCategory.catering:
      rate = TaxRates.kgCateringFlat;
      break;
  }
  final tax = income * rate;
  final paymentNote = kgActivity == KgActivityCategory.catering
      ? 'фиксированная ставка независимо от способа оплаты'
      : '${kgCashPayment ? "наличный" : "безналичный"} расчёт';
  return TaxEstimate(
    country: country,
    income: income,
    regimeName: 'Единый налог',
    lines: [
      TaxLineItem(
        label: kgActivity.label,
        amount: tax,
        note: '${(rate * 100).toStringAsFixed(0)}% ($paymentNote)',
      ),
    ],
  );
}
