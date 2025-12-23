class Policy {
  final String id;
  final String title;
  final String description;
  final String category;
  final int supportPercentage;
  final int opposePercentage;
  final String totalVotes;
  final String timeLeft;
  final DateTime createdAt;

  Policy({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.supportPercentage,
    required this.opposePercentage,
    required this.totalVotes,
    required this.timeLeft,
    required this.createdAt,
  });

  // JSON serialization
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      supportPercentage: json['supportPercentage'] ?? 0,
      opposePercentage: json['opposePercentage'] ?? 0,
      totalVotes: json['totalVotes'] ?? '0',
      timeLeft: json['timeLeft'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'supportPercentage': supportPercentage,
      'opposePercentage': opposePercentage,
      'totalVotes': totalVotes,
      'timeLeft': timeLeft,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
