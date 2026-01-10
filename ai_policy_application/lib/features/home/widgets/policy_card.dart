import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/policy.dart';
import '../../../providers/policy_provider.dart';
import '../../../data/services/api_service.dart';  // ✅ ADD THIS
import '../../policy/details/policy_details_screen.dart';

class PolicyCard extends StatefulWidget {  // ✅ CHANGED: StatefulWidget
  final Policy policy;

  const PolicyCard({
    super.key,
    required this.policy,
  });

  @override
  State<PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<PolicyCard> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _voteResults;
  bool _isLoadingVotes = true;

  @override
  void initState() {
    super.initState();
    _loadVoteResults();
  }

  // ✅ NEW: Load vote results from backend
  Future<void> _loadVoteResults() async {
    try {
      final results = await _apiService.getVoteResults(int.parse(widget.policy.id));
      if (mounted) {
        setState(() {
          _voteResults = results;
          _isLoadingVotes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVotes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use backend data if available, otherwise use policy data
    final totalVotes = _voteResults?['total_votes'] ?? widget.policy.totalVotes;
    final supportPercentage = _voteResults?['support_percentage'] ?? widget.policy.supportPercentage;
    final opposePercentage = _voteResults?['oppose_percentage'] ?? widget.policy.opposePercentage;

    return InkWell(
      onTap: () async {
        final shouldRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PolicyDetailsScreen(policy: widget.policy),
          ),
        );

        // ✅ UPDATED: Refresh both provider and card vote data
        if (shouldRefresh == true && context.mounted) {
          await context.read<PolicyProvider>().fetchPoliciesFromBackend();
          await _loadVoteResults();  // ✅ Reload vote counts
        }
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
                      widget.policy.category,
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
                    widget.policy.timeLeft,
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
                widget.policy.title,
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
                widget.policy.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ✅ UPDATED: Voting Progress with loading state
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _isLoadingVotes
                  ? SizedBox(
                      height: 20,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.primaryPurple.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _buildVoteLabel('Support', supportPercentage),
                            const Spacer(),
                            _buildVoteLabel('Oppose', opposePercentage),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: supportPercentage / 100,
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

            // ✅ UPDATED: Footer with live vote count
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
                  // ✅ UPDATED: Show live vote count
                  Text(
                    '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
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
    switch (widget.policy.category.toLowerCase()) {
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
