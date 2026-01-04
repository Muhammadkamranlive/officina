 import 'package:client/AppColors/AppColors.dart';
 import 'package:flutter/material.dart';
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
  Widget customButton({
    required String text,
    required Future<void> Function()? onPressed,
    required Size size,
    required bool isLoading
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
          child: isLoading
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


 Widget customButtonAsync({
    required String text,
    required VoidCallback onPressed,
    required Size size,
    bool isLoading = false,
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
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
