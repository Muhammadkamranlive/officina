import 'package:client/AppColors/AppColors.dart';
import 'package:client/JobSeekerDashboard/JobSeekerDash.dart';
import 'package:client/JobSeekerDashboard/JoblistsForJobSeekers/JobListScreen.dart';
import 'package:client/Recruiter/Chat/ChatListScreen.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerProfilesScreen.dart';

import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';

class MainShellJobSeeker extends StatefulWidget {
  const MainShellJobSeeker({super.key});

  @override
  State<MainShellJobSeeker> createState() => _MainShellJobSeekerState();
}

class _MainShellJobSeekerState extends State<MainShellJobSeeker>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // 🔑 Navigator keys (one per tab)
  final _homeKey    = GlobalKey<NavigatorState>();
  final _jobsKey    = GlobalKey<NavigatorState>();
  final _chatKey    = GlobalKey<NavigatorState>();
  final _paymentKey = GlobalKey<NavigatorState>();

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
    final screens = [
      _tabNavigator(_homeKey, const JobSeekDashboardScreen()),
      _tabNavigator(_jobsKey, const JobSeekerHomeScreen()),
      const SizedBox(), // FAB slot
      _tabNavigator(_chatKey,  ChatListScreen()),
      _tabNavigator(_paymentKey, const JobSeekerProfilesScreen()),
    ];

    return WillPopScope(
      onWillPop: () async {
        final currentNavigator = [
          _homeKey,
          _jobsKey,
          null,
          _chatKey,
          _paymentKey,
        ][_currentIndex];

        if (currentNavigator?.currentState?.canPop() ?? false) {
          currentNavigator!.currentState!.pop();
          return false;
        }
        return true; // exit app
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: screens),

        /// 🔹 Floating Action Button
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: _gradientGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {
               Navigator.pushNamed(
                  context,
                  AppRoutes.recruiterAddJobScreen,
                  arguments: JobFormMode.create,
                );
            },
            child: const Icon(Icons.add, size: 30,color: AppColors.white),
          ),
        ),

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

                // FAB placeholder
                const SizedBox(width: 60),

                _navItem(Icons.messenger, 3, "Messages"),
                _navItem(Icons.people_alt_sharp, 4, "Profiles"),
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
            null,
            _chatKey,
            _paymentKey,
          ][index];

          navigator?.currentState?.popUntil((r) => r.isFirst);
          
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
