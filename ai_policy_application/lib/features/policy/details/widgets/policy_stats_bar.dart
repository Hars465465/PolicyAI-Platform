import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../models/policy.dart';


class PolicyStatsBar extends StatelessWidget {
  final Policy policy;

  const PolicyStatsBar({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(Icons.people_outline, '66,000', 'Participants'),
          _buildDivider(),
          _buildStat(Icons.comment_outlined, '2', 'Comments'),
          _buildDivider(),
          _buildStat(Icons.visibility_outlined, '158K', 'Views'),
          _buildDivider(),
          _buildStat(Icons.how_to_vote, '89%', 'Support', isPercentage: true),
        ],
      ),
    );
  }
  
  Widget _buildStat(IconData icon, String value, String label, {bool isPercentage = false}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isPercentage ? AppTheme.successGreen : AppTheme.textLight,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPercentage ? AppTheme.successGreen : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
