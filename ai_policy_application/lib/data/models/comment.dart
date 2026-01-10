class Comment {
  final int id;
  final String text;
  final int policyId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;
  final bool isOwn;

  Comment({
    required this.id,
    required this.text,
    required this.policyId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.isOwn,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      text: json['text'] as String,
      policyId: json['policy_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String? ?? 'Unknown User',
      userAvatar: json['user_avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwn: json['is_own'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'policy_id': policyId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'created_at': createdAt.toIso8601String(),
      'is_own': isOwn,
    };
  }
}
  