class AppConstants {
  // App info
  static const String appName = 'AI Policy Platform';
  static const String appTagline = 'Your Voice, Your Democracy';

  // API base (for later phases)
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Policy categories
  static const List<String> categories = [
    'All',
    'Education',
    'Healthcare',
    'Infrastructure',
    'Technology',
    'Agriculture',
    'Housing',
  ];

  // Vote stances
  static const String voteSupport = 'support';
  static const String voteNeutral = 'neutral';
  static const String voteOppose = 'oppose';

  // Local storage keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserName = 'user_name';
  static const String keyVoteHistory = 'vote_history';
}
