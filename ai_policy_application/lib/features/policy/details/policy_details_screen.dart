import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/policy.dart';

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
  bool? _userVote;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _handleVote(bool isSupport) {
    // Force rebuild to show the selected state
    setState(() {
      _userVote = isSupport;
    });
    
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSupport ? Icons.thumb_up : Icons.thumb_down,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(isSupport ? 'You support this policy!' : 'You oppose this policy!'),
          ],
        ),
        backgroundColor: isSupport ? AppTheme.successGreen : AppTheme.warningRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
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

          // Voting Results Chart (First Card)
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
                  _buildPollChart(),
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
                        '${widget.policy.totalVotes} total votes',
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

      // Fixed Bottom Voting Buttons
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
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: () => _handleVote(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userVote == false ? AppTheme.warningRed : Colors.white,
                      foregroundColor: _userVote == false ? Colors.white : AppTheme.warningRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppTheme.warningRed,
                          width: 2,
                        ),
                      ),
                      elevation: _userVote == false ? 4 : 0,
                    ),
                    icon: Icon(
                      _userVote == false ? Icons.check_circle : Icons.thumb_down_outlined,
                      size: 20,
                    ),
                    label: Text(
                      _userVote == false ? 'Opposed' : 'Oppose',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: () => _handleVote(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userVote == true ? AppTheme.successGreen : Colors.white,
                      foregroundColor: _userVote == true ? Colors.white : AppTheme.successGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppTheme.successGreen,
                          width: 2,
                        ),
                      ),
                      elevation: _userVote == true ? 4 : 0,
                    ),
                    icon: Icon(
                      _userVote == true ? Icons.check_circle : Icons.thumb_up_outlined,
                      size: 20,
                    ),
                    label: Text(
                      _userVote == true ? 'Supported' : 'Support',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollChart() {
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
                    value: widget.policy.supportPercentage.toDouble(),
                    title: '${widget.policy.supportPercentage}%',
                    color: AppTheme.successGreen,
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: widget.policy.opposePercentage.toDouble(),
                    title: '${widget.policy.opposePercentage}%',
                    color: AppTheme.warningRed,
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
                _buildLegendItem('Support', AppTheme.successGreen, widget.policy.supportPercentage),
                const SizedBox(height: 16),
                _buildLegendItem('Oppose', AppTheme.warningRed, widget.policy.opposePercentage),
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
