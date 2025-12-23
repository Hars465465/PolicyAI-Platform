import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/policy.dart';
import '../../policy/details/policy_details_screen.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;

  const PolicyCard({
    super.key,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PolicyDetailsScreen(policy: policy),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      policy.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    policy.timeLeft,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                policy.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
              child: Text(
                policy.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Voting Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildVoteLabel('Support', policy.supportPercentage),
                      const Spacer(),
                      _buildVoteLabel('Oppose', policy.opposePercentage),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: policy.supportPercentage / 100,
                      minHeight: 4,
                      backgroundColor: AppTheme.warningRed.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.how_to_vote_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${policy.totalVotes} votes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: AppTheme.primaryPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteLabel(String label, int percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: label == 'Support'
                ? AppTheme.successGreen
                : AppTheme.warningRed,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $percentage%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (policy.category.toLowerCase()) {
      case 'healthcare':
        return Colors.red.shade400;
      case 'education':
        return Colors.blue.shade400;
      case 'infrastructure':
        return Colors.orange.shade400;
      case 'technology':
        return Colors.purple.shade400;
      case 'agriculture':
        return Colors.green.shade400;
      case 'housing':
        return Colors.teal.shade400;
      default:
        return AppTheme.primaryPurple;
    }
  }
}
