import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/finer_theme.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      // SettingsProvider.load() was kicked off in main() at the same time
      // the splash timer started; it's a couple of SharedPreferences reads
      // so 3s is comfortably enough, but wait explicitly rather than assume.
      while (!settings.isLoaded) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      if (!mounted) return;
      final nextScreen =
          settings.onboardingDone ? const MainScreen() : const OnboardingScreen();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinerColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: FinerColors.heroGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background orbs
              Positioned(
                top: -80,
                right: -80,
                child: _buildOrb(200, FinerColors.primary.withValues(alpha: 0.15)),
              ),
              Positioned(
                bottom: 100,
                left: -60,
                child: _buildOrb(160, FinerColors.accent.withValues(alpha: 0.1)),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    _buildLogo()
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // FINER wordmark
                    _buildWordmark()
                        .animate()
                        .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms)
                        .fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 12),

                    // Tagline
                    const Text(
                      'AI Финансовый Ассистент',
                      style: TextStyle(
                        color: FinerColors.textSecondary,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 60),

                    // Loading indicator
                    _buildLoader()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 900.ms),
                  ],
                ),
              ),

              // Version
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: FinerColors.textHint,
                    fontSize: 12,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: FinerColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: FinerColors.primary.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ).createShader(bounds),
          child: const Text(
            'F',
            style: TextStyle(
              color: Colors.black,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: FinerColors.primaryGradient,
      ).createShader(bounds),
      child: const Text(
        'FINER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 40,
      height: 3,
      child: LinearProgressIndicator(
        backgroundColor: FinerColors.primary.withValues(alpha: 0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(FinerColors.primary),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
