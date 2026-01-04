// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/EmailAuth/EmailAuth.dart';
import 'package:client/Authentication/phoneAuth/PhoneAuth.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../routes/app_routes.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<Register> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: size.width / 1.1,
              height: size.height / 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.09),
              ),
            ),
          ),
          SizedBox(
            height: size.height,
            child: Center(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  child: SizedBox(
                    height: size.height,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.2),
                                  
                          // Title
                          Text(
                            "Join Officina",
                            style: TextStyle(
                              
                              fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenCeladon,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                                  
                          // Subtitle
                          Text(
                            "Create an account to get started with Officina",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                                  
                          // Sign Up with Phone
                          _customButton(
                            text: "Sign Up with Phone",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PhoneAuth()),
                              );
                            },
                            size: size,
                          ),
                                  
                          SizedBox(height: size.height * 0.02),
                                  
                          // Sign Up with Email
                          _customButton(
                            text: "Sign Up with Email",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EmailAuth()),
                              );
                            },
                            size: size,
                          ),
                                  
                          
                          SizedBox(height: size.height * 0.02),
                          // Social Media Buttons
                          _socialLoginButton(
                            size,
                            text: "Sign Up with Google",
                            onPressed: () async {},
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
                          _socialLoginButton(
                            size,
                            text: "Sign Up with Apple",
                            onPressed: () async {},
                            backgroundColor: Colors.black,
                            icon: const Icon(Icons.apple, color: Colors.white, size: 39),
                          ),
                         SizedBox(height: size.height * 0.02),
                          // Already have an account?
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: Text(
                              "Already have an account",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                              
                        ],
                      ),
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

  // Custom TextField Widget
  Widget _customTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      padding: const EdgeInsets.all(2), // border thickness
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.white, // keep inner field white for clear input visibility
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          keyboardType: inputType,
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          cursorColor: AppColors.green,
          style: const TextStyle(color: Colors.black),
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
          child: Row(
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
}
