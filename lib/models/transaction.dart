import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late bool isIncome;

  @HiveField(4)
  late String category;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  String? note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.note,
  });
}

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late double savedAmount;

  @HiveField(4)
  late String emoji;

  @HiveField(5)
  late DateTime deadline;

  @HiveField(6)
  late String color;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.emoji,
    required this.deadline,
    required this.color,
  });

  double get progress => savedAmount / targetAmount;
}

class TransactionCategory {
  static const Map<String, Map<String, dynamic>> categories = {
    'Продукты': {'icon': 0xe25a, 'color': 0xFF00C896},      // shopping_cart
    'Транспорт': {'icon': 0xe530, 'color': 0xFF4FC3F7},     // directions_car
    'Кафе': {'icon': 0xe1bc, 'color': 0xFFFFB347},          // restaurant
    'Зарплата': {'icon': 0xe257, 'color': 0xFF6C63FF},      // attach_money
    'Здоровье': {'icon': 0xe3fc, 'color': 0xFFFF5C7A},      // favorite
    'Развлечения': {'icon': 0xe405, 'color': 0xFF9C3FE4},   // movie
    'Одежда': {'icon': 0xe3da, 'color': 0xFFFFD700},        // checkroom
    'Дом': {'icon': 0xe318, 'color': 0xFFFF8C42},           // home
    'Фриланс': {'icon': 0xe165, 'color': 0xFF00D8A8},       // laptop
    'Другое': {'icon': 0xe25b, 'color': 0xFF9090B0},        // category
  };

  static List<String> get all => categories.keys.toList();
  static List<String> get incomeCategories => ['Зарплата', 'Фриланс', 'Другое'];
  static List<String> get expenseCategories =>
      categories.keys.where((k) => !incomeCategories.contains(k)).toList();
}
