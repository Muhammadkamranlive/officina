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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<PhoneAuth> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String get _enteredOtp => _otpControllers.map((e) => e.text).join();

  bool _isValidAlgerianPhone(String phone) {
    final regex = RegExp(r'^[567]\d{8}$');
    return regex.hasMatch(phone);
  }

  String get _fullPhoneNumber => "+213${_phoneController.text.trim()}";

  String? _verificationId;
  bool _otpSent = false;

  late UserRole selectedRole;
  @override
  void initState() {
    super.initState();
    selectedRole = context.read<RoleSelectionProvider>().role!;
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      showCustomToast("Enter phone number");
      return;
    }

    if (!_isValidAlgerianPhone(phone)) {
      showCustomToast(
        "Enter a valid Algerian number (5, 6 or 7 followed by 8 digits)",
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOtp(
      phone: _fullPhoneNumber, // +213XXXXXXXXX
      onCodeSent: (verificationId) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _otpFocusNodes.first.requestFocus();
        });

        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
        });
        showCustomToast("OTP sent to $_fullPhoneNumber");
      },
      onError: (error) {
        setState(() => _isLoading = false);
        showCustomToast(error);
      },
    );
  }

  Future<void> _verifyOtp() async {
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
    smsCode: _enteredOtp, // 👈 from OTP boxes
    role: selectedRole,
  );

  setState(() => _isLoading = false);

  if (user != null) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
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
          
          SafeArea(
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
                      SizedBox(height: size.height * 0.1),
                  
                      Text(
                        "Welcome to Officina",
                        style: TextStyle(
                          fontSize: size.width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                  
                      SizedBox(height: size.height * 0.015),
                  
                      Text(
                        _otpSent
                            ? "Enter the verification code sent to your phone"
                            : "Sign up using your Algerian phone number",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  
                      SizedBox(height: size.height * 0.05),
                      if(!_otpSent)...[
                        Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.greenCeladon,
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            // 🇩🇿 Flag
                            Image.asset(
                              "assets/dz.png",
                              width: 28,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                  
                            const SizedBox(width: 8),
                  
                            // +213
                            const Text(
                              "+213",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  
                            const SizedBox(width: 10),
                  
                            // Phone input
                            Expanded(
                              child: TextField(
                                enabled: !_otpSent,
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
                  
                      SizedBox(height: size.height * 0.02),
                      ],
                      if (_otpSent) ...[
                        Text(
                          "Enter 6-digit code",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                  
                        SizedBox(height: size.height * 0.02),
                  
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
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
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.6,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.2,
                                    ),
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
                                    
                      customButton(
                        text: _otpSent ? "Verify OTP" : "Send OTP",
                        onPressed: _isLoading
                            ? null
                            : _otpSent
                            ? _verifyOtp
                            : _sendOtp,
                        size: size,
                        isLoading: _isLoading,
                      ),
                  
                      // Already have an account?
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          "Already have an account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  
                      SizedBox(width: size.width * 0.04),
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
