import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/vote.dart';

class VoteProvider extends ChangeNotifier {
  static const String _storageKey = 'user_votes_v1';

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

  Future<void> castVote({
    required String policyId,
    required VoteStance stance,
  }) async {
    _votes[policyId] = Vote(policyId: policyId, stance: stance);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> clearAllVotes() async {
    _votes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
