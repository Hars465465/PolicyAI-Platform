import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../models/policy.dart';
import '../../../../data/models/vote.dart';
import '../../../../providers/vote_provider.dart';

class VoteButtons extends StatelessWidget {
  final Policy policy;

  const VoteButtons({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoteProvider>(
      builder: (context, voteProvider, _) {
        final currentVote = voteProvider.getVoteForPolicy(policy.id)?.stance;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: _buildVoteButton(
                    context: context,
                    label: 'Support',
                    color: AppTheme.successGreen,
                    icon: Icons.thumb_up_outlined,
                    isSelected: currentVote == VoteStance.support,
                    onTap: () => _handleVote(
                      context,
                      policy.id,
                      VoteStance.support,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoteButton(
                    context: context,
                    label: 'Neutral',
                    color: Colors.grey.shade700,
                    icon: Icons.horizontal_rule,
                    isSelected: currentVote == VoteStance.neutral,
                    onTap: () => _handleVote(
                      context,
                      policy.id,
                      VoteStance.neutral,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoteButton(
                    context: context,
                    label: 'Oppose',
                    color: Colors.red.shade600,
                    icon: Icons.thumb_down_outlined,
                    isSelected: currentVote == VoteStance.oppose,
                    onTap: () => _handleVote(
                      context,
                      policy.id,
                      VoteStance.oppose,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleVote(
    BuildContext context,
    String policyId,
    VoteStance stance,
  ) async {
    final voteProvider = context.read<VoteProvider>();
    await voteProvider.castVote(policyId: policyId, stance: stance);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your vote: ${stance.name.toUpperCase()}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
