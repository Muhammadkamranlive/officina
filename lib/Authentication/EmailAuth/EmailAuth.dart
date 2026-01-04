// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  State<EmailAuth> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late UserRole selectedRole;
  @override
  void initState() {
    super.initState();
    selectedRole = context.read<RoleSelectionProvider>().role!;
  }
  Future<void> _signup() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      showCustomToast("Password do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        name: 'Kamran Ashraf',
        email: email,
        phone: '3434343332322',
        password: password,
        role: selectedRole,
      );

      Navigator.pushNamed(context, AppRoutes.login);
    } catch (e) {
      showCustomToast(e.toString());
    } finally {
      setState(() => _isLoading = false);
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
          
          SafeArea(
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
                  
                       Text(
                        "Welcome to Officina",
                        style: TextStyle(
                          fontSize: size.width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                  
                      SizedBox(height: size.height * 0.015),
                  
                      // ✅ Subtitle (Email-specific)
                      Text(
                        "Sign up using your email and password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  
                      SizedBox(height: size.height * 0.05),
                  
                      // Email
                      customTextField(
                        "Email",
                        _emailController,
                        TextInputType.emailAddress,
                      ),
                  
                      SizedBox(height: size.height * 0.02),
                  
                      // Password
                      customTextField(
                        "Password",
                        _passwordController,
                        TextInputType.text,
                        isPassword: true,
                      ),
                  
                      SizedBox(height: size.height * 0.02),
                  
                      // Confirm Password
                      customTextField(
                        "Confirm Password",
                        _confirmPasswordController,
                        TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                  
                      SizedBox(height: size.height * 0.04),
                  
                      // Sign Up Button
                      customButton(
                        text: "Sign Up",
                        onPressed: _isLoading ? null : _signup,
                        size: size,
                        isLoading: _isLoading,
                      ),
                  
                      SizedBox(height: size.height * 0.03),
                  
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: const Text(
                          "Already have an account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
