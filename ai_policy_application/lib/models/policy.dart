class Policy {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? aiSummary;
  final List<String> pros;  // ✅ Add this
  final List<String> cons;  // ✅ Add this
  final int supportPercentage;
  final int opposePercentage;
  final int totalVotes;
  final String timeLeft;
  
  Policy({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.aiSummary,
    this.pros = const [],      // ✅ Add this
    this.cons = const [],      // ✅ Add this
    required this.supportPercentage,
    required this.opposePercentage,
    required this.totalVotes,
    required this.timeLeft,
  });
  
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      aiSummary: json['ai_summary'],
      pros: List<String>.from(json['pros'] ?? []),  // ✅ Add this
      cons: List<String>.from(json['cons'] ?? []),  // ✅ Add this
      supportPercentage: json['support_percentage'],
      opposePercentage: json['oppose_percentage'],
      totalVotes: json['total_votes'],
      timeLeft: json['time_left'],
    );
  }
}
