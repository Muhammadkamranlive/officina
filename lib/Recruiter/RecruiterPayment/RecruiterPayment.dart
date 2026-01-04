import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterPayment/transfer_money.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/widgets/credit_card.dart';
import 'package:client/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecruiterPayment extends StatelessWidget {
  const RecruiterPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // set white for body below gradient
      body: SafeArea(
        child:Column(
          children: [
            const DashboardHeader(),
            const SizedBox(height: 16),
             Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  /// Content with Credit Card & Transactions
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 167),
                        child: const Column(
                          children: [
                            SizedBox(height: 80),
                            TransactionList(),
                            SizedBox(height: 30),
                            // TransferMoney(),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
          
                      const Positioned(
                        top: 20,
                        left: 25,
                        right: 25,
                        child: CreditCard(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ),
          ],
        ),
        
      ),
      
    );
  }
}

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final _repoRecruiter = RecruiterRepository();
  Recruiter? _profile; // 🔥 store profile
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await _repoRecruiter.getByUid(user.userId);

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),

          const SizedBox(width: 14),

          // Info Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Payments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 18, // set your desired width
                    height: 18, // set your desired height
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _profile?.pharmacyName ?? "—",
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _profile?.city ?? '',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Notification Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
