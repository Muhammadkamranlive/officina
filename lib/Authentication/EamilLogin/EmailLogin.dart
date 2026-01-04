// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/LoginPhone/LoginPhone.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !isValidEmail(email)) {
      showCustomToast("Please enter a valid email");
      return;
    }
    if (password.isEmpty) {
      showCustomToast("Please enter password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(email: email, password: password);

      if (user == null) {
        showCustomToast("Login failed: user not found");
        return;
      }

      context.read<AuthProvider>().setUser(user);
      await _navigateBasedOnRole(user);
    } finally {
      setState(() => _isLoading = false);
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const RecruiterAccountScreen(mode: AccountFormMode.create),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
        }
        break;
      case UserRole.jobSeeker:
        Navigator.pushReplacementNamed(context, AppRoutes.jobSeekerDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Top circle background
          Positioned(
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
          ),

          // Centered content
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: size.height,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          "Login to Officina",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),

                        // Subtitle
                        Text(
                          "Secure login using your email",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),

                        // Email Input
                        customTextField("Email", _emailController, TextInputType.emailAddress),

                        SizedBox(height: size.height * 0.02),

                        // Password Input
                        customTextField("Password", _passwordController, TextInputType.text, isPassword: true),

                        SizedBox(height: size.height * 0.02),

                        // Login Button
                        customButtonAsync(
                          text: "Sign In",
                          onPressed: _login,
                          size: size,
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: size.height * 0.02),
                        // Create new account
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            "Create new account",
                            style: TextStyle(color: AppColors.green,fontSize: 16,
                            fontWeight: FontWeight.w500),
                          ),
                        ),
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

}

class ForgetText extends StatelessWidget {
  const ForgetText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        child: Text(
          "Forgot your password?",
          style: TextStyle(color: AppColors.green),
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
      "Welcome Back!\nSecure & Simple Login",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.width * 0.05,
        fontWeight: FontWeight.w700,
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
      "Login here",
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
