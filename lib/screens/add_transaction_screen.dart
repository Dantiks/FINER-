import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/finance_provider.dart';
import '../models/country.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isIncome = false;
  String _category = TransactionCategory.expenseCategories.first;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  late AppCountry _country;

  List<String> get _categories =>
      _isIncome ? TransactionCategory.incomeCategories : TransactionCategory.expenseCategories;

  @override
  void initState() {
    super.initState();
    // Default to whichever currency tab the user is currently viewing;
    // they can still switch it below for the dual-currency case.
    _country = context.read<FinanceProvider>().displayCountry;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await context.read<FinanceProvider>().addTransaction(
      title: title,
      amount: amount,
      isIncome: _isIncome,
      category: _category,
      note: _noteController.text.trim(),
      date: _selectedDate,
      country: _country,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinerColors.background,
      appBar: AppBar(
        backgroundColor: FinerColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: FinerColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Новая транзакция'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income / Expense toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Currency / country
            _buildCountryToggle(),
            const SizedBox(height: 16),

            // Amount
            _buildField(
              label: 'Сумма (${_country.currencySymbol})',
              controller: _amountController,
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              hint: 'Например: 15000',
            ),
            const SizedBox(height: 16),

            // Title
            _buildField(
              label: 'Название',
              controller: _titleController,
              icon: Icons.edit_rounded,
              hint: 'Например: Продукты в Магнум',
            ),
            const SizedBox(height: 16),

            // Category
            _buildCategoryPicker(),
            const SizedBox(height: 16),

            // Date
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Note
            _buildField(
              label: 'Заметка (необязательно)',
              controller: _noteController,
              icon: Icons.notes_rounded,
              hint: 'Дополнительная информация',
            ),
            const SizedBox(height: 32),

            // Save button
            GradientButton(
              label: _isLoading ? 'Сохраняю...' : 'Сохранить',
              icon: Icons.check_rounded,
              onTap: _isLoading ? () {} : _save,
              gradient: _isIncome ? FinerColors.incomeGradient : FinerColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Валюта',
          style: TextStyle(
            color: FinerColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: AppCountry.values.map((c) {
            final selected = c == _country;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _country = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? FinerColors.primary.withValues(alpha: 0.18)
                        : FinerColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? FinerColors.primary
                          : FinerColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${c.code} · ${c.currencySymbol}',
                        style: TextStyle(
                          color: selected ? FinerColors.textPrimary : FinerColors.textSecondary,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FinerColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleButton('Расход', false, FinerColors.expense)),
          Expanded(child: _toggleButton('Доход', true, FinerColors.income)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isIncome, Color color) {
    final selected = _isIncome == isIncome;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isIncome = isIncome;
          _category = _categories.first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: isIncome ? FinerColors.incomeGradient : FinerColors.expenseGradient,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? (isIncome ? Colors.black : Colors.white)
                  : FinerColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: FinerColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: FinerColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: FinerColors.textHint, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Категория',
          style: TextStyle(
            color: FinerColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final selected = cat == _category;
            final catData = TransactionCategory.categories[cat];
            final color = Color(catData?['color'] ?? 0xFF9090B0);
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.2) : FinerColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : FinerColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? color : FinerColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дата',
          style: TextStyle(
            color: FinerColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: FinerColors.primary,
                      surface: FinerColors.surfaceCard,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FinerColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: FinerColors.textHint, size: 18),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                  style: const TextStyle(color: FinerColors.textPrimary, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
