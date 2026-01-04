import 'package:client/AppColors/AppColors.dart';
import 'package:client/widgets/credit_card.dart';
import 'package:flutter/material.dart';

class TransferMoney extends StatelessWidget {
  const TransferMoney({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Attached Payment cards",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Choose card",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              _customButton(
                text: 'Add Card',
                onPressed: () {},
                size: size,
                gradient: AppColors.gradientgreen,
                shadowColor: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CreditCard(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Custom Button Widget
Widget _customButton({
  required String text,
  required void Function()? onPressed,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // important
        shadowColor: Colors.transparent, // remove default shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600, // SemiBold = premium
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
