import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/finer_theme.dart';
import '../widgets/common_widgets.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '💰',
      title: 'Контроль финансов',
      subtitle: 'Отслеживайте доходы и расходы в реальном времени. Умная аналитика покажет, куда уходят деньги.',
      color: FinerColors.primary,
      gradient: FinerColors.primaryGradient,
    ),
    _OnboardingPage(
      emoji: '🤖',
      title: 'AI-Ассистент',
      subtitle: 'Персональный советник 24/7. Задайте вопрос о финансах, налогах или правах — получите ответ мгновенно.',
      color: FinerColors.accent,
      gradient: FinerColors.incomeGradient,
    ),
    _OnboardingPage(
      emoji: '🎯',
      title: 'Достигайте целей',
      subtitle: 'Ставьте финансовые цели и следите за прогрессом. FINER поможет накопить на мечту.',
      color: Color(0xFFFFB347),
      gradient: FinerColors.goldGradient,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinerColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _buildPage(_pages[i]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.color.withValues(alpha: 0.08),
            FinerColors.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji in glowing circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: page.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    page.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 48),

              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: FinerColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, duration: 400.ms, delay: 100.ms)
                  .fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: 16),

              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: FinerColors.textSecondary,
                  fontSize: 16,
                  height: 1.6,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, duration: 400.ms, delay: 200.ms)
                  .fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentPage == _pages.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FinerColors.background.withValues(alpha: 0),
            FinerColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothPageIndicator(
            controller: _controller,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              dotColor: FinerColors.textHint,
              activeDotColor: FinerColors.primary,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (!isLast)
                Expanded(
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(color: FinerColors.textSecondary),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: isLast ? 'Начать' : 'Далее',
                  icon: isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
  });
}
