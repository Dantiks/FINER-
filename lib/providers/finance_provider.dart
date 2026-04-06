import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class FinanceProvider extends ChangeNotifier {
  late Box<Transaction> _transactionBox;
  late Box<Goal> _goalBox;
  final _uuid = const Uuid();

  List<Transaction> get transactions =>
      _transactionBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Goal> get goals => _goalBox.values.toList();

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  double get savingsRate => totalIncome > 0
      ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0, 100)
      : 0;

  // Monthly breakdown
  Map<String, double> get monthlyExpenses {
    final map = <String, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    return map;
  }

  // Category breakdown
  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
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
  }) async {
    final t = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      isIncome: isIncome,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
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

  Future<void> _seedSampleData() async {
    final now = DateTime.now();
    final sampleData = [
      ('Зарплата', 350000.0, true, 'Зарплата', now.subtract(const Duration(days: 2))),
      ('Продукты Магнум', 12500.0, false, 'Продукты', now.subtract(const Duration(days: 1))),
      ('Uber', 2800.0, false, 'Транспорт', now.subtract(const Duration(days: 1))),
      ('Кофе & Завтрак', 4200.0, false, 'Кафе', now),
      ('Фриланс проект', 85000.0, true, 'Фриланс', now.subtract(const Duration(days: 3))),
      ('Аренда квартиры', 120000.0, false, 'Дом', now.subtract(const Duration(days: 5))),
      ('Netflix', 5900.0, false, 'Развлечения', now.subtract(const Duration(days: 7))),
      ('Apteka', 8700.0, false, 'Здоровье', now.subtract(const Duration(days: 4))),
    ];

    for (final d in sampleData) {
      await addTransaction(
        title: d.$1,
        amount: d.$2,
        isIncome: d.$3,
        category: d.$4,
        date: d.$5,
      );
    }
  }
}
