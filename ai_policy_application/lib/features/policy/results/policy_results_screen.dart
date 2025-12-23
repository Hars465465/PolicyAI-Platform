import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/vote.dart';
import '../../../models/policy.dart';

import '../../../providers/vote_provider.dart';

class PolicyResultsScreen extends StatelessWidget {
  final Policy policy;

  const PolicyResultsScreen({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Vote Results'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VoteProvider>(
        builder: (context, voteProvider, _) {
          // In Phase 1, we show mock aggregated data
          // In Phase 2, this will come from backend API
          final mockResults = _getMockResults();
          final userVote = voteProvider.getVoteForPolicy(policy.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy Title Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        policy.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Your Vote Card (if user voted)
                if (userVote != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getVoteColor(userVote.stance).withOpacity(0.1),
                          _getVoteColor(userVote.stance).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getVoteColor(userVote.stance).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getVoteColor(userVote.stance),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getVoteIcon(userVote.stance),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Vote',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userVote.stance.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getVoteColor(userVote.stance),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Pie Chart Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        'Vote Distribution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                value: mockResults['support']!.toDouble(),
                                title: '${mockResults['support']}%',
                                color: AppTheme.successGreen,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: mockResults['neutral']!.toDouble(),
                                title: '${mockResults['neutral']}%',
                                color: Colors.grey.shade600,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: mockResults['oppose']!.toDouble(),
                                title: '${mockResults['oppose']}%',
                                color: Colors.red.shade600,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegend('Support', AppTheme.successGreen),
                          _buildLegend('Neutral', Colors.grey.shade600),
                          _buildLegend('Oppose', Colors.red.shade600),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Breakdown
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Total Votes',
                        '66,234',
                        Icons.how_to_vote,
                        AppTheme.primaryPurple,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Support',
                        '59,123 (${mockResults['support']}%)',
                        Icons.thumb_up,
                        AppTheme.successGreen,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Neutral',
                        '3,211 (${mockResults['neutral']}%)',
                        Icons.horizontal_rule,
                        Colors.grey.shade600,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Oppose',
                        '3,900 (${mockResults['oppose']}%)',
                        Icons.thumb_down,
                        Colors.red.shade600,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Note about mock data
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These are demo statistics. Real voting data will be available in Phase 2.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, int> _getMockResults() {
    // Mock data for Phase 1
    // Phase 2 will fetch from backend API
    return {
      'support': 89,
      'neutral': 5,
      'oppose': 6,
    };
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getVoteColor(VoteStance stance) {
    switch (stance) {
      case VoteStance.support:
        return AppTheme.successGreen;
      case VoteStance.neutral:
        return Colors.grey.shade600;
      case VoteStance.oppose:
        return Colors.red.shade600;
    }
  }

  IconData _getVoteIcon(VoteStance stance) {
    switch (stance) {
      case VoteStance.support:
        return Icons.thumb_up;
      case VoteStance.neutral:
        return Icons.horizontal_rule;
      case VoteStance.oppose:
        return Icons.thumb_down;
    }
  }
}