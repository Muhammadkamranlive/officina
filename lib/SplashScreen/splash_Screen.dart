import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/AppColors/AppColors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _glowPulse;

  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    /// LOGO ENTRY
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutExpo,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    /// GLOW BREATH
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowPulse = Tween<double>(begin: .2, end: .6).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    /// TEXT
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleSlide = Tween(
      begin: const Offset(0, .35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(.4, 1, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      _glowController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      _textController.forward();
    });

    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.greenCeladon,
              Color(0xFF5F9E87),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// LUXURY O LOGO
              /// LUXURY O LOGO (FIXED: bigger & visually centered)
FadeTransition(
  opacity: _logoFade,
  child: ScaleTransition(
    scale: _logoScale,
    child: AnimatedBuilder(
      animation: _glowPulse,
      builder: (_, __) {
        return Container(
          height: 100, 
          width: 100,  // ⬅️ BIGGER
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.beigeWhite,
                AppColors.pinkO,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pinkO.withOpacity(_glowPulse.value),
                blurRadius: 40,   // ⬅️ stronger glow
                spreadRadius: 3,
              ),
            ],
          ),
          child: Text(
            "O",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 90, // ⬅️ BIGGER LOGO TEXT
              fontWeight: FontWeight.w700,
              height: 1,     // ⬅️ fixes vertical centering
              color: AppColors.greenCeladon,
            ),
          ),
        );
      },
    ),
  ),
),

              const SizedBox(height: 24),

              /// OFFICINA + TAGLINE
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    children: [
                      Text(
                        "OFFICINA",
                        style: TextStyle(
                          fontSize: 45,
                          letterSpacing: 2.6,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          "Your opportunity is here",
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.3,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
