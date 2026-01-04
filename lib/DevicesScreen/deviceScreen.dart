import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Security status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 120, child: Placeholder()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Session History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text('James Carter'),
                      subtitle: Text('Canada'),
                    ),
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text('Ayesha Rahman'),
                      subtitle: Text('Brazil'),
                    ),
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text('Daniel Kim'),
                      subtitle: Text('Germany'),
                    ),
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text('Sophia Lopez'),
                      subtitle: Text('France'),
                    ),
                    ListTile(
                      leading: CircleAvatar(),
                      title: Text('Omar Hassan'),
                      subtitle: Text('India'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
