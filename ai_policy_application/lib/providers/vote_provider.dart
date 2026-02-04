import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/vote.dart';
import '../data/services/api_service.dart';
import '../data/services/device_service.dart';

class VoteProvider extends ChangeNotifier {
  static const String _storageKey = 'user_votes_v1';
  
  final ApiService _api = ApiService();

  // policyId -> Vote
  final Map<String, Vote> _votes = {};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Map<String, Vote> get votes => Map.unmodifiable(_votes);

  Vote? getVoteForPolicy(String policyId) => _votes[policyId];

  int get totalVotes => _votes.length;

  int get supportCount =>
      _votes.values.where((v) => v.stance == VoteStance.support).length;

  int get neutralCount =>
      _votes.values.where((v) => v.stance == VoteStance.neutral).length;

  int get opposeCount =>
      _votes.values.where((v) => v.stance == VoteStance.oppose).length;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      _votes.clear();
      for (final item in decoded) {
        final vote = Vote.fromJson(item as Map<String, dynamic>);
        _votes[vote.policyId] = vote;
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _votes.values.map((v) => v.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  // ✅ NEW: Cast vote with backend API call
  Future<void> castVote({
    required String policyId,
    required VoteStance stance,
  }) async {
    try {
      // Get device ID
      final deviceId = await DeviceService.getDeviceId();
      
      // Convert stance to backend format
      String backendStance;
      switch (stance) {
        case VoteStance.support:
          backendStance = 'support';
          break;
        case VoteStance.oppose:
          backendStance = 'oppose';
          break;
        case VoteStance.neutral:
          backendStance = 'neutral';
          break;
      }
      
      debugPrint('🗳️ Casting vote: Policy $policyId, Stance: $backendStance');
      
      // ✅ Call backend API
      await _api.castVote(
        int.parse(policyId),
        backendStance,
        deviceId,
      );
      
      debugPrint('✅ Vote cast successfully!');
      
      // Save locally
      _votes[policyId] = Vote(policyId: policyId, stance: stance);
      await _saveToStorage();
      
      // Update UI
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error casting vote: $e');
      rethrow;
    }
  }

  // ✅ NEW: Withdraw vote (delete from backend)
  Future<void> withdrawVote(String policyId) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      
      debugPrint('🗑️ Withdrawing vote for policy $policyId');
      
      // ✅ Call backend API
      await _api.deleteVote(int.parse(policyId), deviceId);
      
      debugPrint('✅ Vote withdrawn successfully!');
      
      // Remove locally
      _votes.remove(policyId);
      await _saveToStorage();
      
      // Update UI
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error withdrawing vote: $e');
      rethrow;
    }
  }

  // ✅ NEW: Sync votes from backend
  Future<void> syncVotesFromBackend(List<int> policyIds) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      
      for (final policyId in policyIds) {
        try {
          final result = await _api.getMyVote(policyId, deviceId);
          
          if (result['voted'] == true && result['stance'] != null) {
            VoteStance stance;
            switch (result['stance']) {
              case 'support':
                stance = VoteStance.support;
                break;
              case 'oppose':
                stance = VoteStance.oppose;
                break;
              case 'neutral':
                stance = VoteStance.neutral;
                break;
              default:
                continue;
            }
            
            _votes[policyId.toString()] = Vote(
              policyId: policyId.toString(),
              stance: stance,
            );
          }
        } catch (e) {
          debugPrint('⚠️ Could not sync vote for policy $policyId: $e');
        }
      }
      
      await _saveToStorage();
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error syncing votes: $e');
    }
  }

  Future<void> clearAllVotes() async {
    _votes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
