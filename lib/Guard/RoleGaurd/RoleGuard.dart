import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? unauthorizedScreen;

  const RoleGuard({
    required this.child,
    required this.allowedRoles,
    this.unauthorizedScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // Not logged in
    if (user == null) {
      return const LoginScreenWrapper(); // simple redirect to login
    }

    // Role not allowed
    if (!allowedRoles.contains(user.role)) {
      return unauthorizedScreen ?? const UnauthorizedScreen();
    }

    // Role allowed
    return child;
  }
}


// Example placeholder screens
class LoginScreenWrapper extends StatelessWidget {
  const LoginScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
    return const SizedBox.shrink();
  }
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("You are not authorized to view this page"),
      ),
    );
  }
}