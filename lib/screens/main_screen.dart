import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/finer_theme.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'legal_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  SettingsProvider? _settings;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    LegalScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep FinanceProvider's display currency in sync with the user's
    // chosen primary country (onboarding, or changed later in Profile).
    final settings = context.read<SettingsProvider>();
    if (_settings != settings) {
      _settings?.removeListener(_syncDisplayCountry);
      _settings = settings;
      _settings!.addListener(_syncDisplayCountry);
      _syncDisplayCountry();
    }
  }

  void _syncDisplayCountry() {
    if (!mounted) return;
    context.read<FinanceProvider>().setDisplayCountry(_settings!.primaryCountry);
  }

  @override
  void dispose() {
    _settings?.removeListener(_syncDisplayCountry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: FinerColors.surface,
        border: Border(
          top: BorderSide(
            color: FinerColors.primary.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final isSelected = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FinerColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? FinerColors.primary : FinerColors.textHint,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? FinerColors.primary : FinerColors.textHint,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Главная'),
    _NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Счета'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Аналитика'),
    _NavItem(Icons.balance_outlined, Icons.balance_rounded, 'Право'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Профиль'),
  ];
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
