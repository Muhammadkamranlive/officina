import 'package:flutter/material.dart';

class AppColors {
  static const background      = Color(0xFFE8F5E9);
  static const card            = Colors.white;
  static const white           = Color(0xFFFFFFFF);
  static const textDark        = Color(0xFF1A1A1A);
  static const textLight       = Color(0xFF6F7A73);
  static const yellow          = Color(0xFFF5D96C);
  static const green           = Color(0xFF0A6B58);
  static const orange          = Color(0xFFF4B851);
  static const red             = Color(0xFFD96A5F);
  static const lightgreen      = Color(0xFF2ECC71);
  static const blue            = Color(0xFF4AA3FF);
  static const lightBlue       = Color(0xFF85C1FF);
  static const pink            = Color(0xFFFFA1C0);
  
  static const Color greenCeladon = Color(0xFF69A88D);
  static const Color pinkO        = Color(0xFFE5BDB5);
  static const Color beigeWhite = Color(0xFFF3EEE6);


  static const darkGreen           = Color.fromARGB(255, 15, 81, 100);
  static const gradientgreen1      = LinearGradient(colors:  [Color.fromARGB(255, 15, 81, 100),Color.fromARGB(255, 15, 81, 100)]);
  static const gradientgreen       = LinearGradient(colors:  [Color(0xFF69A88D),Color(0xFF69A88D)]);
  static const gradientdarkgreen   = LinearGradient(colors:  [Color(0xFF69A88D),Color(0xFF69A88D)]);
  static const gradientOrange      = LinearGradient(colors:  [Colors.orange,Colors.orange]);
  static const gradientBlue        = LinearGradient(colors:  [Color.fromARGB(255, 4, 22, 68),Color(0xFF4AA3FF)]);
  static const gradientPink        = LinearGradient(colors:  [Colors.pink,Color.fromARGB(176, 233, 30, 98)]);
  static const gradientYellow      = LinearGradient(colors:  [Colors.amber,Colors.amberAccent, Color(0xFFF5D96C)]);
  static const gradientRed         = LinearGradient(colors:  [Colors.red,Colors.redAccent, Color(0xFFD96A5F)]);
}


class AdminColors {
  static const bgGradient = LinearGradient(
    colors: [Color(0xFF6A5AE0), Color(0xFF8F85F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFFF6F7FB), Color(0xFFEDEEFF)],
  );

  static const purple = Color(0xFF6A5AE0);
  static const pink = Color(0xFFEC4899);
  static const teal = Color(0xFF2DD4BF);
  static const textDark = Color(0xFF2E2E48);
}


List<BoxShadow> premiumShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 12),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 6,
    offset: const Offset(0, 2),
  ),
];

LinearGradient calmGreenGradient = const LinearGradient(
  colors: [
    Color(0xFF1E7F6D),
    Color(0xFF4FB6A3),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
LinearGradient calmBlueGradient = const LinearGradient(
  colors: [
    Color(0xFF2F5D8A),
    Color(0xFF6FA3D9),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
LinearGradient calmTealGradient = const LinearGradient(
  colors: [
    Color(0xFF3A8F8F),
    Color(0xFF7FCFC4),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
LinearGradient calmNeutralGradient = const LinearGradient(
  colors: [
    Color(0xFF5F6C7B),
    Color(0xFF9CA3AF),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);