import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
void showCustomToast(String message){
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG, fontSize: 18, backgroundColor:AppColors.green, gravity: ToastGravity.SNACKBAR);
}


void showCustomToast1(
  BuildContext context,
  String message, {
  int seconds = 20,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontSize: 18, color: Colors.white),
    ),
    backgroundColor: AppColors.green,
    duration: Duration(seconds: seconds),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
