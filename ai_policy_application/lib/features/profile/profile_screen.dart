import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../data/models/vote.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vote_provider.dart';
import '../../providers/policy_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.secondaryBlue,
                    ],
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            auth.phoneNumber ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Citizen Voter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Consumer<VoteProvider>(
              builder: (context, voteProvider, _) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Overall Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Votes',
                              voteProvider.totalVotes.toString(),
                              Icons.how_to_vote,
                              AppTheme.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Points',
                              '${voteProvider.totalVotes * 10}',
                              Icons.stars,
                              Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Vote Breakdown
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Support',
                              voteProvider.supportCount.toString(),
                              Icons.thumb_up,
                              AppTheme.successGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Neutral',
                              voteProvider.neutralCount.toString(),
                              Icons.horizontal_rule,
                              Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Oppose',
                              voteProvider.opposeCount.toString(),
                              Icons.thumb_down,
                              Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Voting History Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppTheme.textDark,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Voting History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Voting History List
          Consumer2<VoteProvider, PolicyProvider>(
            builder: (context, voteProvider, policyProvider, _) {
              if (voteProvider.totalVotes == 0) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No votes yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start voting on policies to see your history',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final votes = voteProvider.votes.values.toList().reversed.toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vote = votes[index];
                      final policy = policyProvider.getPolicyById(vote.policyId);

                      if (policy == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVoteHistoryCard(
                          policy.title,
                          policy.category,
                          vote.stance,
                        ),
                      );
                    },
                    childCount: votes.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer2<AuthProvider, VoteProvider>(
                builder: (context, auth, voteProvider, _) {
                  return Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear Vote History?'),
                              content: const Text(
                                'This will delete all your votes from this device.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await voteProvider.clearAllVotes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vote history cleared'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear Vote History'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await auth.logout();
                            // Navigate back to login/splash
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SizedBox(), // Replace with your LoginScreen
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteHistoryCard(String title, String category, VoteStance stance) {
    Color stanceColor;
    IconData stanceIcon;

    switch (stance) {
      case VoteStance.support:
        stanceColor = AppTheme.successGreen;
        stanceIcon = Icons.thumb_up;
        break;
      case VoteStance.neutral:
        stanceColor = Colors.grey.shade600;
        stanceIcon = Icons.horizontal_rule;
        break;
      case VoteStance.oppose:
        stanceColor = Colors.red.shade600;
        stanceIcon = Icons.thumb_down;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stanceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stanceIcon, color: stanceColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: stanceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stance.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
