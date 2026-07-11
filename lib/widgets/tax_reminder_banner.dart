import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/finer_theme.dart';

/// A periodic nudge to open the tax calculator, shown roughly every
/// [_intervalDays] days. This is the lightweight retention lever from
/// FINER_Strategic_Analysis_V2 section 9.1 ("churn matters more than
/// price" — prioritize retention features over ARPU features).
///
/// Deliberately does NOT reference specific filing deadlines: we don't have
/// a verified recurring filing calendar for either country's tax regime,
/// and showing a wrong date would be worse than a generic reminder.
class TaxReminderBanner extends StatefulWidget {
  final VoidCallback onTap;
  const TaxReminderBanner({super.key, required this.onTap});

  @override
  State<TaxReminderBanner> createState() => _TaxReminderBannerState();
}

class _TaxReminderBannerState extends State<TaxReminderBanner> {
  static const _prefsKey = 'tax_reminder_last_shown';
  static const _intervalDays = 14;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _checkShouldShow();
  }

  Future<void> _checkShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownMillis = prefs.getInt(_prefsKey);
    final shouldShow = lastShownMillis == null ||
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastShownMillis)).inDays >=
            _intervalDays;
    if (shouldShow && mounted) {
      setState(() => _visible = true);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, DateTime.now().millisecondsSinceEpoch);
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FinerColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinerColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Давно не проверяли, сколько уже набежало налогов? Загляните в калькулятор.',
              style: TextStyle(color: FinerColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
          ),
          TextButton(
            onPressed: () {
              _dismiss();
              widget.onTap();
            },
            child: const Text('Открыть', style: TextStyle(color: FinerColors.info, fontSize: 12.5)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: FinerColors.textHint, size: 16),
            onPressed: _dismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
