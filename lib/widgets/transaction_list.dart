import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today, Dec 29", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("All Transactions", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          // Subscription Payment
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9), // soft greenish background
              child: Icon(Icons.payment, color: Colors.green),
            ),
            title: Text("Yearly Subscription"),
            subtitle: Text("Pharmacy Pro Plan"),
            trailing: Text(
              "-\$49.99",
              style: TextStyle(color: Colors.red),
            ),
          ),
          const Divider(color: Colors.grey),
          
          const Divider(color: Colors.grey),
          // Subscription Renewal
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFFFF3E0), // soft orange
              child: Icon(Icons.refresh, color: Colors.orange),
            ),
            title: Text("Subscription Renewal"),
            subtitle: Text("Premium Recruiter Plan"),
            trailing: Text(
              "-\$99.99",
              style: TextStyle(color: Colors.red),
            ),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
