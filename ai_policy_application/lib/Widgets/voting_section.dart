import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/policy_provider.dart';

class VotingSection extends StatefulWidget {
  final String policyId;

  const VotingSection({
    Key? key,
    required this.policyId,
  }) : super(key: key);

  @override
  State<VotingSection> createState() => _VotingSectionState();
}

class _VotingSectionState extends State<VotingSection> {
  bool _isVoting = false;
  String? _myVote;
  bool _hasVoted = false;
  Map<String, dynamic>? _voteResults;

  @override
  void initState() {
    super.initState();
    _loadVoteStatus();
  }

  Future<void> _loadVoteStatus() async {
    final provider = context.read<PolicyProvider>();
    
    // Check if user already voted
    final myVote = await provider.checkMyVote(widget.policyId);
    
    // Get current results
    final results = await provider.getVoteResults(widget.policyId);
    
    if (mounted) {
      setState(() {
        _hasVoted = myVote['voted'] ?? false;
        _myVote = myVote['stance'];
        _voteResults = results;
      });
    }
  }

  Future<void> _handleVote(String stance) async {
    if (_isVoting || _hasVoted) return;

    setState(() => _isVoting = true);

    try {
      final provider = context.read<PolicyProvider>();
      await provider.voteOnPolicy(widget.policyId, stance);

      if (mounted) {
        setState(() {
          _hasVoted = true;
          _myVote = stance;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Vote submitted: ${_getStanceLabel(stance)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Reload results
        await _loadVoteStatus();
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
        return Colors.green;
      case 'oppose':
        return Colors.red;
      case 'neutral':
        return Colors.orange;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vote Results
        if (_voteResults != null) _buildVoteResults(),
        
        const SizedBox(height: 20),
        
        // Voting Buttons or Already Voted Status
        if (_hasVoted)
          _buildAlreadyVoted()
        else
          _buildVotingButtons(),
      ],
    );
  }

  Widget _buildVoteResults() {
    final total = _voteResults!['total_votes'] ?? 0;
    final supportPct = _voteResults!['support_percentage'] ?? 0;
    final opposePct = _voteResults!['oppose_percentage'] ?? 0;
    final neutralPct = _voteResults!['neutral_percentage'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vote Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$total votes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Support Bar
          _buildVoteBar('Support', supportPct, Colors.green),
          const SizedBox(height: 12),
          
          // Oppose Bar
          _buildVoteBar('Oppose', opposePct, Colors.red),
          const SizedBox(height: 12),
          
          // Neutral Bar
          _buildVoteBar('Neutral', neutralPct, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildVoteBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildVotingButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast Your Vote',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildVoteButton(
                'Support',
                'support',
                Colors.green,
                Icons.thumb_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVoteButton(
                'Oppose',
                'oppose',
                Colors.red,
                Icons.thumb_down,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVoteButton(
                'Neutral',
                'neutral',
                Colors.orange,
                Icons.remove_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoteButton(
    String label,
    String stance,
    Color color,
    IconData icon,
  ) {
    return ElevatedButton(
      onPressed: _isVoting ? null : () => _handleVote(stance),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isVoting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
    );
  }

  Widget _buildAlreadyVoted() {
    final color = _getStanceColor(_myVote ?? 'neutral');
    final icon = _getStanceIcon(_myVote ?? 'neutral');
    final label = _getStanceLabel(_myVote ?? 'neutral');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You have voted',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: color, size: 32),
        ],
      ),
    );
  }
}
