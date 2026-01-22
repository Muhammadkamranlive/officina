import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;
  late Animation<double> _glow;


  @override
void initState() {
  super.initState();

  _mainController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  _glowController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  _fade = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    ),
  );

  _logoScale = Tween<double>(begin: 0.85, end: 1).animate(
    CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutExpo,
    ),
  );

  _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ),
  );

  _glow = Tween<double>(begin: 0.2, end: 0.6).animate(
    CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ),
  );

  _mainController.forward();
  _glowController.repeat(reverse: true);
}



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          /// 🎨 BACKGROUND
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: size.width,
              height: size.height / 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientgreen,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🌟 CENTER CONTENT
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.07,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// 🔮 LOGO
                              ScaleTransition(
                                scale: _logoScale,
                                child: AnimatedBuilder(
                                  animation: _glow,
                                  builder: (_, __) {
                                    return Container(
                                      height: size.width * 0.55,
                                      width: size.width * 0.55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.green
                                                .withOpacity(_glow.value),
                                            blurRadius: 40,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "O",
                                          style: TextStyle(
                                            fontSize: size.width * 0.28,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 28),

                              /// 🏷 TITLE
                              Text(
                                "Authentication with OFFICINA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.085,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green,
                                  letterSpacing: 0.4,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// 🧾 SUBTITLE
                              Text(
                                "Secure & Seamless Login for Everyone\n"
                                "One-Tap Access with Google, Apple SignIn",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// 🔘 BUTTONS
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: size.height * 0.045,
                      left: size.width * 0.06,
                      right: size.width * 0.06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _premiumButton(
                          text: "Sign In",
                          size: size,
                          gradient: AppColors.gradientgreen,
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                        ),
                        _premiumButton(
                          text: "Sign Up",
                          size: size,
                          gradient: AppColors.gradientdarkgreen,
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.selectRole),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}

/// 💎 PREMIUM BUTTON
Widget _premiumButton({
  required String text,
  required Size size,
  required Gradient gradient,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: size.width * 0.4,
    height: size.height * 0.065,
    child: Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    ),
  );
}
