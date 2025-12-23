enum VoteStance { support, neutral, oppose }

class Vote {
  final String policyId;
  final VoteStance stance;

  Vote({required this.policyId, required this.stance});

  Map<String, dynamic> toJson() => {
        'policyId': policyId,
        'stance': stance.name, // support / neutral / oppose
      };

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      policyId: json['policyId'] as String,
      stance: VoteStance.values
          .firstWhere((v) => v.name == json['stance'] as String),
    );
  }
}
