// lib/widgets/home/quick_stats_widget.dart
import 'package:flutter/material.dart';

class QuickStatsWidget extends StatelessWidget {
  final String revenue;
  final String missions;

  const QuickStatsWidget({
    super.key,
    required this.revenue,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.account_balance_wallet_outlined,
            title: "Revenus",
            value: "$revenue FCFA",
            isRevenue: true,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade100),
          _buildStatItem(
            icon: Icons.assignment_outlined,
            title: "Missions",
            value: missions,
            isRevenue: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String title, required String value, required bool isRevenue}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: isRevenue ? const Color(0xFF2F66F6) : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRevenue ? const Color(0xFF2F66F6) : Colors.black,
          ),
        ),
      ],
    );
  }
}