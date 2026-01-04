import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

  Widget customTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen
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
