// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/EamilLogin/EmailLogin.dart';
import 'package:client/Authentication/LoginPhone/LoginPhone.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {

  bool _isLoading = false;
  bool _googleloginLoading = false;
  bool _appleLoginLoading = false;


  final AuthService _authService = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // At least 6 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
    return passwordRegex.hasMatch(password);
  }


  void _loginGoogle() async {
    setState(() => _googleloginLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        showCustomToast("No user found");
        return;
      }

      context.read<AuthProvider>().setUser(user);
      await _navigateBasedOnRole(user);
    } catch (e) {
      showCustomToast1(context, e.toString());
    } finally {
      setState(() => _googleloginLoading = false);
    }
  }

 

  Future<void> _navigateBasedOnRole(AppUser user) async {
    switch (user.role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRoutes.devices);
        break;

      case UserRole.recruiter:
        final profile = await _RecruiterRepo.getByUid(user.userId);

        if (profile == null) {
          // No recruiter profile → create it first
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const RecruiterAccountScreen(mode: AccountFormMode.create),
            ),
          );
        } else {
          // Profile exists → go to app shell
          Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
        }
        break;

      case UserRole.jobSeeker:
        Navigator.pushReplacementNamed(context, AppRoutes.devices);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Shape
          TopCircle(size: size),
          // Main Content
          SizedBox(
            height: size.height,
            child: Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.1),
                
                        // Login Heading
                        LoginText(size: size),

                        SizedBox(height: size.height * 0.02),
                
                        // Subtext
                        WelcomeText(size: size),
                        SizedBox(height: size.height * 0.03),
                     
                        // Sign In Button
                        _customButton(text: "Login with Phone", onPressed:(){
                           Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPhone()),
                                );
                        }, size: size),
                        SizedBox(height: size.height * 0.02),
                        _customButton(
                          text: "Login with Email",
                          onPressed: () {
                             Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EmailLogin()),
                                );
                          },
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.02),
                        // Social Media Buttons
                        _socialLoginButton(
                          size,
                          text: "Login with Google",
                          onPressed: () async {
                            _loginGoogle();
                          },
                          backgroundColor: Colors.transparent,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4285F4), AppColors.greenCeladon],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _AppleLogin(
                          size,
                          text: "Login with Apple",
                          onPressed: () async {},
                          backgroundColor: Colors.black,
                          icon: const Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 39,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        // Create New Account
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.selectRole);
                          },
                          child: Text(
                            "Create new  account",
                            style: TextStyle(color: AppColors.green,fontSize: 16,
                                  fontWeight: FontWeight.w500,),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                
                        SizedBox(width: size.width * 0.03),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _continueText() {
    return Text(
      "Or continue with",
      style: TextStyle(fontSize: 14, color: AppColors.green),
    );
  }

  // Custom Button Widget
  Widget _customButton({
    required String text,
    required void Function() onPressed,
    required Size size,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientgreen,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // important
            shadowColor: Colors.transparent, // remove default shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }


  // Login Buttons Widget
  Widget _socialLoginButton(
    Size size, {
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (gradient != null ? AppColors.green : backgroundColor)
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // important
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _googleloginLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _AppleLogin(
    Size size, {
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Widget icon,
    Gradient? gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (gradient != null ? AppColors.green : backgroundColor)
                  .withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // important
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _appleLoginLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }


 
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Access your Officina account securely with your preferred method",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: size.width * 0.04,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class LoginText extends StatelessWidget {
  const LoginText({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Text(
      "Login Here",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.width * 0.1,
        fontWeight: FontWeight.bold,
        color: AppColors.greenCeladon,
      ),
    );
  }
}

class TopCircle extends StatelessWidget {
  const TopCircle({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: -50,
      child: Container(
        width: size.width / 1.1,
        height: size.height / 1.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withOpacity(0.03),
        ),
      ),
    );
  }
}
