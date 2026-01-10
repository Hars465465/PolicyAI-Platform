class VoteRequest {
  final String deviceId;
  final String stance; // 'support', 'oppose', 'neutral'

  VoteRequest({
    required this.deviceId,
    required this.stance,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'stance': stance,
      };
}

class VoteResponse {
  final int id;
  final int userId;
  final int policyId;
  final String stance;
  final DateTime createdAt;

  VoteResponse({
    required this.id,
    required this.userId,
    required this.policyId,
    required this.stance,
    required this.createdAt,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      id: json['id'],
      userId: json['user_id'],
      policyId: json['policy_id'],
      stance: json['stance'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class VoteResults {
  final int policyId;
  final int totalVotes;
  final int supportCount;
  final int opposeCount;
  final int neutralCount;
  final int supportPercentage;
  final int opposePercentage;
  final int neutralPercentage;

  VoteResults({
    required this.policyId,
    required this.totalVotes,
    required this.supportCount,
    required this.opposeCount,
    required this.neutralCount,
    required this.supportPercentage,
    required this.opposePercentage,
    required this.neutralPercentage,
  });

  factory VoteResults.fromJson(Map<String, dynamic> json) {
    return VoteResults(
      policyId: json['policy_id'],
      totalVotes: json['total_votes'],
      supportCount: json['support_count'],
      opposeCount: json['oppose_count'],
      neutralCount: json['neutral_count'],
      supportPercentage: json['support_percentage'],
      opposePercentage: json['oppose_percentage'],
      neutralPercentage: json['neutral_percentage'],
    );
  }
}

class MyVote {
  final bool voted;
  final String? stance;

  MyVote({required this.voted, this.stance});

  factory MyVote.fromJson(Map<String, dynamic> json) {
    return MyVote(
      voted: json['voted'] ?? false,
      stance: json['stance'],
    );
  }
}
