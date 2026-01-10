import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/policy.dart';
import '../../../providers/policy_provider.dart';
import '../../home/widgets/comments_bottom_sheet.dart';


class PolicyDetailsScreen extends StatefulWidget {
  final Policy policy;


  const PolicyDetailsScreen({
    super.key,
    required this.policy,
  });


  @override
  State<PolicyDetailsScreen> createState() => _PolicyDetailsScreenState();
}


class _PolicyDetailsScreenState extends State<PolicyDetailsScreen>
    with SingleTickerProviderStateMixin {
  String? _userVote; // 'support', 'oppose', 'neutral', or null
  bool _hasVoted = false;
  bool _isVoting = false;
  Map<String, dynamic>? _voteResults;
  late AnimationController _buttonAnimationController;


  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadVoteData();
  }


  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // ✅ Load vote status and results
  Future<void> _loadVoteData() async {
    final provider = context.read<PolicyProvider>();
    
    // Check if backend is available
    if (!provider.useBackend) {
      debugPrint('⚠️ Backend not available for voting');
      return;
    }

    // Check if user already voted
    final myVote = await provider.checkMyVote(widget.policy.id);
    
    // Get current results
    final results = await provider.getVoteResults(widget.policy.id);
    
    if (mounted) {
      setState(() {
        _hasVoted = myVote['voted'] ?? false;
        _userVote = myVote['stance'];
        _voteResults = results;
      });
    }
  }

  // ✅ Handle vote submission with WITHDRAWAL support
  Future<void> _handleVote(String stance) async {
    if (_isVoting) return;

    final provider = context.read<PolicyProvider>();

    // ✅ WITHDRAW VOTE: If clicking same button again
    if (_hasVoted && _userVote == stance) {
      setState(() => _isVoting = true);

      try {
        await provider.withdrawVote(widget.policy.id);

        if (mounted) {
          setState(() {
            _hasVoted = false;
            _userVote = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.undo, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Vote withdrawn!'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          await _loadVoteData();
          
          // ✅ Refresh home screen
          provider.fetchPoliciesFromBackend();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isVoting = false);
        }
      }
      return;
    }

    // ✅ CAST NEW VOTE or CHANGE VOTE
    setState(() => _isVoting = true);

    try {
      await provider.voteOnPolicy(widget.policy.id, stance);

      if (mounted) {
        setState(() {
          _hasVoted = true;
          _userVote = stance;
        });

        _buttonAnimationController.forward().then((_) {
          _buttonAnimationController.reverse();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _getStanceIcon(stance),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(_hasVoted && _userVote != stance
                    ? 'Vote changed to ${_getStanceLabel(stance)}!'
                    : 'Vote submitted: ${_getStanceLabel(stance)}!'),
              ],
            ),
            backgroundColor: _getStanceColor(stance),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await _loadVoteData();
        
        // ✅ Refresh home screen policies
        provider.fetchPoliciesFromBackend();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVoting = false);
      }
    }
  }

  String _getStanceLabel(String stance) {
    switch (stance) {
      case 'support':
        return 'Support';
      case 'oppose':
        return 'Oppose';
      case 'neutral':
        return 'Neutral';
      default:
        return stance;
    }
  }

  Color _getStanceColor(String stance) {
    switch (stance) {
      case 'support':
        return AppTheme.successGreen;
      case 'oppose':
        return AppTheme.warningRed;
      case 'neutral':
        return AppTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStanceIcon(String stance) {
    switch (stance) {
      case 'support':
        return Icons.thumb_up;
      case 'oppose':
        return Icons.thumb_down;
      case 'neutral':
        return Icons.remove_circle_outline;
      default:
        return Icons.circle;
    }
  }


  @override
  Widget build(BuildContext context) {
    // ✅ Use backend results if available
    final displaySupportPct = _voteResults != null 
        ? (_voteResults!['support_percentage'] ?? widget.policy.supportPercentage)
        : widget.policy.supportPercentage;
    
    final displayOpposePct = _voteResults != null
        ? (_voteResults!['oppose_percentage'] ?? widget.policy.opposePercentage)
        : widget.policy.opposePercentage;
    
    final displayTotalVotes = _voteResults != null
        ? (_voteResults!['total_votes']?.toString() ?? widget.policy.totalVotes)
        : widget.policy.totalVotes;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppTheme.textDark,
                ),
              ),
              onPressed: () {
                // ✅ Refresh home screen when going back
                Navigator.pop(context, true);
              },
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: AppTheme.textDark,
                  ),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bookmark_border,
                    size: 20,
                    color: AppTheme.textDark,
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 40, bottom: 16, right: 20),
              title: Text(
                widget.policy.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),


          // Voting Results Chart
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.policy.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.policy.timeLeft,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Voting Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPollChart(displaySupportPct, displayOpposePct),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.how_to_vote_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$displayTotalVotes total votes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


          // Comments Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsBottomSheet(
                      policyId: int.parse(widget.policy.id),
                      policyTitle: widget.policy.title,
                    ),
                  );
                },
                icon: const Icon(Icons.comment_outlined, size: 18),
                label: const Text('Comments'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  side: const BorderSide(color: AppTheme.primaryPurple),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),


          const SliverToBoxAdapter(child: SizedBox(height: 16)),


          // Description Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.policy.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),


          // AI Summary Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryPurple.withOpacity(0.1),
                    AppTheme.secondaryBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.secondaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAISection(
                    'Pros',
                    Icons.check_circle_outline,
                    AppTheme.successGreen,
                    _getMockPros(),
                  ),
                  const SizedBox(height: 16),
                  _buildAISection(
                    'Cons',
                    Icons.warning_outlined,
                    AppTheme.warningOrange,
                    _getMockCons(),
                  ),
                  const SizedBox(height: 16),
                  _buildAISection(
                    'Risks',
                    Icons.error_outline,
                    AppTheme.warningRed,
                    _getMockRisks(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Budget Estimate: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _getMockBudget(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),


          // Impact Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: AppTheme.infoBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Expected Impact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildImpactItem(Icons.people_outline, 'Affects 2.5M+ citizens'),
                  _buildImpactItem(Icons.location_on_outlined, 'Implementation in 12 states'),
                  _buildImpactItem(Icons.calendar_today_outlined, 'Rollout starts Q2 2026'),
                ],
              ),
            ),
          ),


          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),


      // ✅ UPDATED: Fixed Bottom Voting Buttons with WITHDRAWAL
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasVoted) _buildVotedIndicator(),
              if (_hasVoted) const SizedBox(height: 12),
              _buildVotingButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Show which vote user cast (with hint to click again to withdraw)
  Widget _buildVotedIndicator() {
    final color = _getStanceColor(_userVote ?? 'neutral');
    final label = _getStanceLabel(_userVote ?? 'neutral');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            'You voted: $label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(Click again to withdraw)',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Voting buttons (highlight current vote)
  Widget _buildVotingButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildVoteButton(
            'Oppose',
            'oppose',
            AppTheme.warningRed,
            Icons.thumb_down_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildVoteButton(
            'Neutral',
            'neutral',
            AppTheme.warningOrange,
            Icons.remove_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildVoteButton(
            'Support',
            'support',
            AppTheme.successGreen,
            Icons.thumb_up_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildVoteButton(String label, String stance, Color color, IconData icon) {
    final isSelected = _hasVoted && _userVote == stance;
    
    return ElevatedButton(
      onPressed: _isVoting ? null : () => _handleVote(stance),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
        elevation: isSelected ? 4 : 0,
      ),
      child: _isVoting
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: isSelected ? Colors.white : color,
                strokeWidth: 2,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : icon,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }


  Widget _buildPollChart(int supportPct, int opposePct) {
    final neutralPct = _voteResults != null 
      ? (_voteResults!['neutral_percentage'] ?? 0)
      : 100 - supportPct - opposePct;
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: supportPct.toDouble(),
                    title: '$supportPct%',
                    color: AppTheme.successGreen,
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: opposePct.toDouble(),
                    title: '$opposePct%',
                    color: AppTheme.warningRed,
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: neutralPct.toDouble(),
                    title: '$neutralPct%',
                    color: AppTheme.warningOrange,
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Support', AppTheme.successGreen, supportPct),
                const SizedBox(height: 16),
                _buildLegendItem('Oppose', AppTheme.warningRed, opposePct),
                const SizedBox(height: 16),
                if (neutralPct > 0) ...[
                const SizedBox(height: 12),
                _buildLegendItem('Neutral', AppTheme.warningOrange, neutralPct),
              ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLegendItem(String label, Color color, int percentage) {
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildAISection(String title, IconData icon, Color color, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildImpactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ],
      ),
    );
  }


  List<String> _getMockPros() {
    switch (widget.policy.category) {
      case 'Education':
        return [
          'Improves digital literacy across rural and urban areas',
          'Creates skill-based employment opportunities',
          'Enhances educational infrastructure nationwide',
        ];
      case 'Healthcare':
        return [
          'Universal healthcare access for all citizens',
          'Reduces out-of-pocket medical expenses',
          'Strengthens public health infrastructure',
        ];
      default:
        return [
          'Positive economic impact expected',
          'Benefits multiple sectors',
          'Long-term sustainable growth',
        ];
    }
  }


  List<String> _getMockCons() {
    switch (widget.policy.category) {
      case 'Education':
        return [
          'High initial implementation cost',
          'Requires extensive teacher training programs',
        ];
      case 'Healthcare':
        return [
          'Substantial budget allocation required',
          'Implementation challenges in remote areas',
        ];
      default:
        return [
          'Significant budget requirement',
          'Complex implementation logistics',
        ];
    }
  }


  List<String> _getMockRisks() {
    return [
      'Delays in rollout timeline',
      'Potential cost overruns',
      'Regional implementation gaps',
    ];
  }


  String _getMockBudget() {
    switch (widget.policy.category) {
      case 'Education':
        return '₹15,000 Crore';
      case 'Healthcare':
        return '₹25,000 Crore';
      case 'Infrastructure':
        return '₹50,000 Crore';
      default:
        return '₹10,000 Crore';
    }
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
