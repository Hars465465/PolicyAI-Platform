class AISummary {
  final String summary;
  final List<String> pros;
  final List<String> cons;
  final List<String> risks;
  final String budgetEstimate;

  AISummary({
    required this.summary,
    required this.pros,
    required this.cons,
    required this.risks,
    required this.budgetEstimate,
  });

  // JSON serialization
  factory AISummary.fromJson(Map<String, dynamic> json) {
    return AISummary(
      summary: json['summary'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      risks: List<String>.from(json['risks'] ?? []),
      budgetEstimate: json['budgetEstimate'] ?? json['budget_estimate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'pros': pros,
      'cons': cons,
      'risks': risks,
      'budgetEstimate': budgetEstimate,
    };
  }
}
