// ignore: file_names
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
                color: Colors.purple.withOpacity(0.03),
              ),
            ),
          ),

          // Main Content
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),

                // Profile Image
                Image.asset("assets/avatar.png", width: size.width * 0.3),
                SizedBox(height: size.height * 0.03),

                // Welcome Title
                Text(
                  "Welcome Back!\n Sabir Bugti",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // User Details
                _userDetailCard("Email", "sabirbugti532@gmail.com"),
                _userDetailCard("User ID", "12312312232"),
                _userDetailCard("Password", "Hidden for security"),

                SizedBox(height: size.height * 0.04),

                // Logout Button
                _customButton("Logout", Colors.purple, Colors.white, () {
                  Navigator.pushNamed(context, AppRoutes.login);
                }, size),

                SizedBox(height: size.height * 0.06),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // User Detail Card Widget
  Widget _userDetailCard(String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
        leading: Icon(Icons.info, color: Colors.purple),
      ),
    );
  }

  // Custom Button Widget
  Widget _customButton(
      String text,
      Color color,
      Color textColor,
      VoidCallback onPressed,
      Size size,
      ) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, color: textColor)),
      ),
    );
  }
}
