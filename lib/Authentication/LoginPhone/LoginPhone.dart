// ignore: file_names
import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';

import 'package:client/Server/Enums/AdminEnum.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Model/JobSeeker.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/routes/app_routes.dart';

import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class LoginPhone extends StatefulWidget {
  const LoginPhone({super.key});

  @override
  State<LoginPhone> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPhone> {
  final TextEditingController _phoneController = TextEditingController();

  // 6-digit OTP controllers and focus nodes
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  String get _enteredOtp =>
      _otpControllers.map((e) => e.text).join();

  String? _verificationId;
  bool _otpSent = false;
  bool _isLoading = false;

  final AuthService _authService           = AuthService();
  final RecruiterRepository _RecruiterRepo = RecruiterRepository();


  Future<void> _sendOtpLogin() async {
  final rawPhone = _phoneController.text.trim();

  if (rawPhone.isEmpty || rawPhone.length != 9) {
    showCustomToast("Enter valid Algerian number");
    return;
  }

  final phone = "+213$rawPhone"; // 🔥 FIX

  setState(() => _isLoading = true);

  await _authService.sendOtp(
    phone: phone,
    onCodeSent: (verificationId) {
      setState(() {
        _verificationId = verificationId;
        _otpSent = true;
        _isLoading = false;
      });
      showCustomToast("OTP sent");
    },
    onError: (error) {
      setState(() => _isLoading = false);
      showCustomToast(error);
    },
  );
}

  Future<void> _verifyOtpLogin() async {
    if (_verificationId == null) {
      showCustomToast("OTP not sent yet");
      return;
    }

    if (_enteredOtp.length != 6) {
      showCustomToast("Enter complete 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: _enteredOtp,
      role: UserRole.recruiter,
    );

    setState(() => _isLoading = false);

    if (user == null) {
      showCustomToast("Login failed");
      // Clear OTP boxes on failure
      for (final c in _otpControllers) c.clear();
      _otpFocusNodes.first.requestFocus();
      return;
    }

    context.read<AuthProvider>().setUser(user);
    await _navigateBasedOnRole(user);
  }

   Future<void> _navigateBasedOnRole(AppUser user) async {
    switch (user.role) {
      case UserRole.admin:
        AdminRepository _AdminRepo = AdminRepository();
        final profile = await _AdminRepo.getByUid(user.userId);
        if (profile == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminAccountScreen(mode: AdminFormMode.create),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
        }
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
        } else 
        {
          Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
        }
      break;
      case UserRole.jobSeeker:
        JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
        final profile = await _jobSeekerRepo.getByUid(user.userId);
        if (profile == null) 
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const JobSeekerAccountScreen(mode: JobSeekerFormMode.create),
            ),
          );
        } else 
        {
          Navigator.pushReplacementNamed(context, AppRoutes.jobSeekerDash);
        }
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
        automaticallyImplyLeading: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background circle
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: size.width / 1.1,
              height: size.height / 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.05),
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
                          style: TextStyle(
                            fontSize: size.width * 0.1,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.015),

                        // Subtitle
                        Text(
                          "Secure login using your phone number",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // Phone input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 1.6),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/dz.png",
                                width: 28,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "+213",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "5XXXXXXXX",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // OTP Boxes
                        if (_otpSent) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: size.width * 0.12,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.green, width: 2.2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _otpFocusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _otpFocusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],

                        // Button
                        customButton(
                          text: _otpSent ? "Verify OTP" : "Login with Phone",
                          onPressed: _otpSent ? _verifyOtpLogin : _sendOtpLogin,
                          size: size,
                          isLoading: _isLoading,
                        ),

                       
                        SizedBox(height: size.height * 0.01),

                        // Create new account
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            "Create new account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: AppColors.green)
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

