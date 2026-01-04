// import 'package:client/Authentication/ForgotPassword/forgot_screen.dart';
// import 'package:client/Authentication/Login/login.dart';
// import 'package:client/Authentication/Register/register.dart';
// import 'package:client/BottomNavigation/MainShell.dart';
// import 'package:client/DevicesScreen/deviceScreen.dart';
// import 'package:client/JobSeekersList/JobSeekersList.dart';
// import 'package:client/ProfileScreen/ProfileScreen.dart';
// import 'package:client/Recruiter/AddJobs/recruiterAddJobScreen.dart';
// import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
// import 'package:client/Recruiter/RecruiterJobList/RecruiterJobListScreen.dart';

// import 'package:client/SplashScreen/splash_Screen.dart';
// import 'package:client/onBoarding/onBoarding.dart';
// import 'package:flutter/material.dart';

// class AppRoutes {
//   static const String splash     = '/';
//   static const String login      = '/login';
//   static const String register   = '/register';
//   static const String onboarding = "/onboarding";
//   static const String devices    = "/devices";
//   static const String jobseeker    = "/jobseeker";
//   static const String profile    = "/profile";
//   static const String forgotPassword = "/forgotPassword";
//   static const String recruiterAddJobScreen = "/recruiterAddJobScreen";
//   static const String recruiterJoblistingScreen = "/recruiterJoblistingScreen";
//   static const String jobDetail = "/jobDetail";
//   static const String mainShell = "/mainShell";
//   static const String editJob = "/editJob";
//   static const String editrecruiterAccountScreen = "/editrecruiterAccountScreen";
//   static Map<String, WidgetBuilder> routes = {
//     login: (context) => const Login(),
//     register: (context) => const Register(),
//     onboarding: (context) => const OnboardingScreen(),
//     splash: (context) => const SplashScreen(),
//     devices: (context) => const DevicesScreen(),
//     jobseeker: (context) => const JobSeekersList(),
//     profile: (context) => const ProfileScreen(),
//     forgotPassword: (context) => const ForgotPasswordScreen(),
//     mainShell: (context) => const MainShell(),
//     recruiterAddJobScreen: (context) => const RecruiterAddJobScreen(),
//     recruiterJoblistingScreen: (context) => const RecruiterJobListScreen(),
//     jobDetail: (context) => const RecruiterJobDetailScreen(),
//     editrecruiterAccountScreen: (context) =>
//     const RecruiterAccountScreen(mode: AccountFormMode.edit),
//      editJob: (context) =>
//     const JobFormScreen(mode: JobFormMode.edit),
   
//   };
// }



import 'package:client/Authentication/ForgotPassword/forgot_screen.dart';
import 'package:client/Authentication/Login/login.dart';
import 'package:client/Authentication/Register/register.dart';
import 'package:client/Authentication/Role/SelectRoleScreen.dart';
import 'package:client/BottomNavigation/MainShell.dart';
import 'package:client/DevicesScreen/deviceScreen.dart';
import 'package:client/Guard/RoleGaurd/RoleGuard.dart';
import 'package:client/JobSeekerDashboard/JobSeekerDash.dart';
import 'package:client/JobSeekerDashboard/AdminDashboardScreen.dart';
import 'package:client/JobSeekersList/JobSeekersList.dart';
import 'package:client/ProfileScreen/ProfileScreen.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Recruiter/RecruiterJobList/RecruiterJobListScreen.dart';
import 'package:client/SplashScreen/splash_Screen.dart';
import 'package:client/onBoarding/onBoarding.dart';
import 'package:flutter/material.dart';
import 'package:client/Server/Enums/UserRole.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = "/onboarding";
  static const String devices = "/devices";
  static const String jobseeker = "/jobseeker";
  static const String profile = "/profile";
  static const String forgotPassword = "/forgotPassword";
  static const String recruiterAddJobScreen = "/recruiterAddJobScreen";
  static const String recruiterJoblistingScreen = "/recruiterJoblistingScreen";
  static const String jobDetail = "/jobDetail";
  static const String mainShell = "/mainShell";
  static const String editJob = "/editJob";
  static const String editrecruiterAccountScreen = "/editrecruiterAccountScreen";
  static const String selectRole= "/SelectRole";
  static const String jobSeekerDashboard='/jobSeekerDashboard';
  static Map<String, WidgetBuilder> routes = {
    // Public / general screens
    splash: (context) => const SplashScreen(),
    login: (context) => const Login(),
    register: (context) => const Register(),
    onboarding: (context) => const OnboardingScreen(),
    devices: (context) => const DevicesScreen(),
    jobseeker: (context) => const JobSeekersList(),
    profile: (context) => const ProfileScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    mainShell: (context) => const MainShell(),
    selectRole :(context)=> const SelectRoleScreen(),
    jobSeekerDashboard :(context)=> const AdminDashboardScreen(),
    // Recruiter-only screens (protected by RoleGuard)
    recruiterAddJobScreen: (context) => RoleGuard(
            allowedRoles: [UserRole.recruiter],
          child: const JobFormScreen(mode: JobFormMode.create),
        ),
    recruiterJoblistingScreen: (context) => RoleGuard(
          allowedRoles: [UserRole.recruiter],
          child: const RecruiterJobListScreen(),
        ),
 
    editrecruiterAccountScreen: (context) => RoleGuard(
          allowedRoles: [UserRole.recruiter],
          child: const RecruiterAccountScreen(mode: AccountFormMode.edit),
        ),
    editJob: (context) => RoleGuard(
          allowedRoles: [UserRole.recruiter],
          child: const JobFormScreen(mode: JobFormMode.edit),
        ),
  };
}
