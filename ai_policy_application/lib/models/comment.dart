class Comment {
  final int id;
  final int policyId;
  final int userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final bool isOwn;

  Comment({
    required this.id,
    required this.policyId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.isOwn,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      policyId: json['policy_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Anonymous',
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      isOwn: json['is_own'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'policy_id': policyId,
      'user_id': userId,
      'user_name': userName,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'is_own': isOwn,
    };
  }
}
