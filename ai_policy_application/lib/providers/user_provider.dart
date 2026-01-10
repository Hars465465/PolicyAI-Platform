import 'package:flutter/foundation.dart';
import '../data/services/api_service.dart';
import '../data/services/device_service.dart';

class VotingHistoryItem {
  final int policyId;
  final String policyTitle;
  final String category;
  final String stance;
  final DateTime votedAt;
  final bool isActive;

  VotingHistoryItem({
    required this.policyId,
    required this.policyTitle,
    required this.category,
    required this.stance,
    required this.votedAt,
    required this.isActive,
  });

  factory VotingHistoryItem.fromJson(Map<String, dynamic> json) {
    return VotingHistoryItem(
      policyId: json['policy_id'],
      policyTitle: json['policy_title'],
      category: json['category'],
      stance: json['stance'],
      votedAt: DateTime.parse(json['voted_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}

class UserProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  Map<String, dynamic>? _userProfile;
  List<VotingHistoryItem> _votingHistory = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // User info
  int? get userId => _userProfile?['user']?['id'];
  String? get userName => _userProfile?['user']?['name'];
  String? get deviceId => _userProfile?['user']?['device_id'];
  DateTime? get createdAt {
    final dateStr = _userProfile?['user']?['created_at'];
    return dateStr != null ? DateTime.tryParse(dateStr) : null;
  }

  // Statistics
  int get totalVotes => _userProfile?['statistics']?['total_votes'] ?? 0;
  int get supportCount => _userProfile?['statistics']?['support_count'] ?? 0;
  int get opposeCount => _userProfile?['statistics']?['oppose_count'] ?? 0;
  int get neutralCount => _userProfile?['statistics']?['neutral_count'] ?? 0;
  int get points => _userProfile?['statistics']?['points'] ?? 0;

  // Voting history
  List<VotingHistoryItem> get votingHistory => _votingHistory;

  /// Fetch user profile from backend
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceId = await DeviceService.getDeviceId();
      _userProfile = await _api.getUserProfile(deviceId);
      debugPrint('✅ User Profile loaded: $_userProfile');
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch voting history from backend
  Future<void> fetchVotingHistory() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final history = await _api.getVotingHistory(deviceId);
      
      _votingHistory = history
          .map<VotingHistoryItem>((json) => VotingHistoryItem.fromJson(json))
          .toList();
      
      debugPrint('✅ Voting History loaded: ${_votingHistory.length} votes');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching history: $e');
      _error = e.toString();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await fetchUserProfile();
    await fetchVotingHistory();
  }

  /// Update user name
  Future<bool> updateUserName(String name) async {
    try {
      final result = await _api.updateUserProfile(name: name);
      
      if (result['success'] == true) {
        // Update local cache
        if (_userProfile != null) {
          _userProfile!['user']['name'] = name;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return false;
    }
  }
}
