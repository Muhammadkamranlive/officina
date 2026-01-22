import 'package:client/AdminPannel/AdminDashboardScreen.dart';
import 'package:client/AdminPannel/AdminJobListScreen.dart';
import 'package:client/AdminPannel/AdminRecruiterListScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Recruiter/Chat/ChatListScreen.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerProfilesScreen.dart';
import 'package:client/Recruiter/RecruiterJobList/RecruiterJobListScreen.dart';

import 'package:client/Recruiter/dashboardSingleScreen.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // 🔑 Navigator keys (one per tab)
  final _homeKey = GlobalKey<NavigatorState>();
  final _jobsKey = GlobalKey<NavigatorState>();
  final _chatKey = GlobalKey<NavigatorState>();
  final _jobSeekersKey = GlobalKey<NavigatorState>();
  final _recruitersKey = GlobalKey<NavigatorState>();
  late AnimationController _controller;

  final Gradient _gradientGreen = AppColors.gradientgreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔹 Navigator wrapper for each tab
  Widget _tabNavigator(GlobalKey<NavigatorState> key, Widget screen) {
    return Navigator(
      key: key,
      onGenerateRoute: (_) {
        return MaterialPageRoute(builder: (_) => screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = 
    [
      _tabNavigator(_homeKey, const AdminDashboardScreen()),
      _tabNavigator(_jobsKey, const AdminJobListScreen()),
      _tabNavigator(_jobSeekersKey, const JobSeekerProfilesScreen()),
      _tabNavigator(_recruitersKey, const RecruitersListScreen()),
      _tabNavigator(_chatKey,  ChatListScreen()),
    ];

    return WillPopScope(
      onWillPop: () async {
        final currentNavigator = [
          _homeKey,
          _jobsKey,
          _jobSeekersKey,
          _recruitersKey,
          _chatKey,
          
        ][_currentIndex];

        if (currentNavigator.currentState?.canPop() ?? false) {
          currentNavigator.currentState!.pop();
          return false;
        }
        return true; // exit app
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: screens),

        /// 🔹 Bottom Navigation
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // evenly distributes space
              children: [
                _navItem(Icons.home, 0, "Home"),
                _navItem(Icons.campaign, 1, "Jobs"),
                _navItem(Icons.people_alt_sharp, 2, "Job Seekers"),
                 _navItem(Icons.person_pin_circle_sharp, 3, "Recruiters"),
                _navItem(Icons.messenger, 4, "Messages"),
               
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Bottom Nav Item
  Widget _navItem(IconData icon, int index, String label) {
    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) {
          // Pop to root of current tab
          final navigator = [
            _homeKey,
            _jobsKey,
            _jobSeekersKey,
            _recruitersKey,
            _chatKey,
            
          ][index];

          navigator.currentState?.popUntil((r) => r.isFirst);
          
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          selected
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return _gradientGreen.createShader(
                          Rect.fromLTWH(
                            -bounds.width +
                                (bounds.width * 2) * _controller.value,
                            0,
                            bounds.width,
                            bounds.height,
                          ),
                        );
                      },
                      child: Icon(icon, color: Colors.white),
                    );
                  },
                )
              : Icon(icon, color: AppColors.textDark),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.green : AppColors.textDark,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
