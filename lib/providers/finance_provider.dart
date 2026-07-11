import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/country.dart';
import '../models/transaction.dart';

class FinanceProvider extends ChangeNotifier {
  late Box<Transaction> _transactionBox;
  late Box<Goal> _goalBox;
  final _uuid = const Uuid();

  // Which currency the aggregate stats below are computed in. Transactions
  // are tagged per-currency (KGS or KZT) and must never be summed together
  // numerically — see AppCountry. Screens that show a single balance/total
  // read this; the raw transaction list can still show both currencies at
  // once (each row renders its own currency symbol).
  AppCountry _displayCountry = AppCountry.kg;
  AppCountry get displayCountry => _displayCountry;

  void setDisplayCountry(AppCountry country) {
    if (_displayCountry == country) return;
    _displayCountry = country;
    notifyListeners();
  }

  List<Transaction> get transactions =>
      _transactionBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  /// Transactions in [_displayCountry]'s currency only — the safe list to
  /// sum for a single-currency total.
  List<Transaction> get displayTransactions =>
      transactions.where((t) => t.country == _displayCountry).toList();

  /// True once the user has logged at least one transaction outside their
  /// primary currency — used to decide whether to show the currency switcher.
  bool get hasMultiCurrencyData =>
      transactions.any((t) => t.country != _displayCountry);

  List<Goal> get goals => _goalBox.values.toList();

  double get totalIncome => displayTransactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => displayTransactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  double get savingsRate => totalIncome > 0
      ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0, 100)
      : 0;

  // Monthly breakdown (display currency only)
  Map<String, double> get monthlyExpenses {
    final map = <String, double>{};
    for (final t in displayTransactions.where((t) => !t.isIncome)) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    return map;
  }

  // Category breakdown (display currency only)
  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in displayTransactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Total income this calendar month in [_displayCountry]'s currency —
  /// the basis for the tax calculator (see services/tax_calculator.dart).
  double get currentMonthIncome {
    final now = DateTime.now();
    return displayTransactions
        .where((t) =>
            t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total expense this calendar month in [_displayCountry]'s currency.
  double get currentMonthExpense {
    final now = DateTime.now();
    return displayTransactions
        .where((t) =>
            !t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> init() async {
    _transactionBox = await Hive.openBox<Transaction>('transactions');
    _goalBox = await Hive.openBox<Goal>('goals');
    if (_transactionBox.isEmpty) {
      await _seedSampleData();
    }
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
    String? note,
    DateTime? date,
    AppCountry? country,
  }) async {
    final t = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      isIncome: isIncome,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
      countryCode: (country ?? _displayCountry).code,
    );
    await _transactionBox.put(t.id, t);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
    notifyListeners();
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required String emoji,
    required DateTime deadline,
    required String color,
  }) async {
    final g = Goal(
      id: _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      savedAmount: 0,
      emoji: emoji,
      deadline: deadline,
      color: color,
    );
    await _goalBox.put(g.id, g);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    final goal = _goalBox.get(id);
    if (goal != null) {
      goal.savedAmount = (goal.savedAmount + amount).clamp(0, goal.targetAmount);
      await goal.save();
      notifyListeners();
    }
  }

  /// Seed data intentionally mixes both currencies — a Bishkek-based
  /// freelancer with KZ clients is exactly the dual-currency persona FINER
  /// targets (see FINER_Strategic_Analysis_V2, section 6.1, option C), so
  /// the demo data should show that from the first launch, not just KZT.
  Future<void> _seedSampleData() async {
    final now = DateTime.now();
    final sampleData = [
      ('Зарплата', 45000.0, true, 'Зарплата', now.subtract(const Duration(days: 2)), AppCountry.kg),
      ('Продукты Народный', 3200.0, false, 'Продукты', now.subtract(const Duration(days: 1)), AppCountry.kg),
      ('Такси', 350.0, false, 'Транспорт', now.subtract(const Duration(days: 1)), AppCountry.kg),
      ('Кофе & Завтрак', 480.0, false, 'Кафе', now, AppCountry.kg),
      ('Фриланс проект (KZ клиент)', 85000.0, true, 'Фриланс', now.subtract(const Duration(days: 3)), AppCountry.kz),
      ('Аренда квартиры', 25000.0, false, 'Дом', now.subtract(const Duration(days: 5)), AppCountry.kg),
      ('Netflix', 5900.0, false, 'Развлечения', now.subtract(const Duration(days: 7)), AppCountry.kz),
      ('Apteka', 8700.0, false, 'Здоровье', now.subtract(const Duration(days: 4)), AppCountry.kz),
    ];

    for (final d in sampleData) {
      await addTransaction(
        title: d.$1,
        amount: d.$2,
        isIncome: d.$3,
        category: d.$4,
        date: d.$5,
        country: d.$6,
      );
    }
  }
}
