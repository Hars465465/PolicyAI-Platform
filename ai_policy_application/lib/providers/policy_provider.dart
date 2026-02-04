import 'package:flutter/foundation.dart';
import '../../models/policy.dart';
import '../../data/services/api_service.dart';
import '../../data/services/device_service.dart';


class PolicyProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Mock data as fallback
  List<Policy> _allPolicies = [
    Policy(
      id: 1,
      title: 'National Education Reform Act 2025',
      description: 'Comprehensive education system overhaul focusing on digital literacy, skill development, and equal access to quality education across urban and rural areas.',
      category: 'Education',
      supportPercentage: 68,
      opposePercentage: 32,
      totalVotes: 45200,
      timeLeft: '5 days left',
    ),
    Policy(
      id: 2,
      title: 'Universal Healthcare Access Program',
      description: 'Initiative to provide free primary healthcare services to all citizens through expanded public health infrastructure and telemedicine integration.',
      category: 'Healthcare',
      supportPercentage: 72,
      opposePercentage: 28,
      totalVotes: 52800,
      timeLeft: '3 days left',
    ),
    Policy(
      id: 3,
      title: 'Green Energy Infrastructure Plan',
      description: 'Nationwide transition to renewable energy sources with solar panel subsidies, wind farms, and electric vehicle charging network expansion.',
      category: 'Infrastructure',
      supportPercentage: 65,
      opposePercentage: 35,
      totalVotes: 38900,
      timeLeft: '7 days left',
    ),
    Policy(
      id: 4,
      title: 'Digital India 2.0 Initiative',
      description: 'Accelerate digital transformation with 5G rollout, cybersecurity framework, and digital skills training for 10 million citizens.',
      category: 'Technology',
      supportPercentage: 78,
      opposePercentage: 22,
      totalVotes: 61400,
      timeLeft: '4 days left',
    ),
    Policy(
      id: 5,
      title: 'Agricultural Modernization Scheme',
      description: 'Support farmers with modern equipment subsidies, direct market access platforms, and crop insurance reforms to boost rural income.',
      category: 'Agriculture',
      supportPercentage: 70,
      opposePercentage: 30,
      totalVotes: 42100,
      timeLeft: '6 days left',
    ),
    Policy(
      id: 6,
      title: 'Urban Housing Development Act',
      description: 'Affordable housing scheme with low-interest loans, rent control measures, and infrastructure development in tier-2 and tier-3 cities.',
      category: 'Housing',
      supportPercentage: 63,
      opposePercentage: 37,
      totalVotes: 36700,
      timeLeft: '8 days left',
    ),
  ];

  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _useBackend = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useBackend => _useBackend;

  List<Policy> get policies {
    if (_searchQuery.isEmpty) {
      return _allPolicies;
    }
    return _allPolicies.where((policy) {
      return policy.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          policy.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          policy.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Policy> getPoliciesByCategory(String category) {
    if (category == 'All') {
      return policies;
    }
    return policies.where((policy) => policy.category == category).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Policy? getPolicyById(String id) {
    try {
      return _allPolicies.firstWhere((policy) => policy.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  // ========== BACKEND INTEGRATION ==========

  /// Fetch policies from backend
  Future<void> fetchPoliciesFromBackend() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📥 Fetching policies from backend...');
      
      final data = await _api.getPolicies();
      
      debugPrint('✅ Received ${data.length} policies from backend');
      
      if (data.isEmpty) {
        debugPrint('⚠️  Backend returned empty array!');
        debugPrint('⚠️  Keeping existing ${_allPolicies.length} mock policies');
        
        _useBackend = false;
        _error = 'Backend has no policies';
        
      } else {
        debugPrint('📦 Sample policy data: ${data[0]}');
        
        // ✅ FIX: Include neutral votes in calculation
        _allPolicies = data.map<Policy>((json) {
          final supportCount = (json['support_count'] as num?)?.toInt() ?? 0;
          final opposeCount = (json['oppose_count'] as num?)?.toInt() ?? 0;
          final neutralCount = (json['neutral_count'] as num?)?.toInt() ?? 0;
          final totalVotes = supportCount + opposeCount + neutralCount;
          
          int supportPercentage;
          int opposePercentage;
          
          if (totalVotes > 0) {
            supportPercentage = ((supportCount / totalVotes) * 100).round();
            opposePercentage = ((opposeCount / totalVotes) * 100).round();
          } else {
            supportPercentage = 50;
            opposePercentage = 50;
          }
          
          return Policy(
            id: int.parse(json['id'].toString()),
            title: json['title']?.toString() ?? 'Untitled Policy',
            description: json['description']?.toString() ?? 'No description available',
            category: json['category']?.toString() ?? 'General',
            supportPercentage: supportPercentage,
            opposePercentage: opposePercentage,
            totalVotes: totalVotes,
            timeLeft: 'Active',
          );
        }).toList();
        
        _useBackend = true;
        _error = null;
        
        debugPrint('✅ Successfully loaded ${_allPolicies.length} policies from backend');
        debugPrint('🎯 Backend status: LIVE ✅');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching from backend: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      _error = e.toString();
      _useBackend = false;
      
      debugPrint('⚠️  Fallback: Using ${_allPolicies.length} mock policies');
      debugPrint('🎯 Backend status: OFFLINE ⚠️');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vote on a policy
  Future<void> voteOnPolicy(String policyId, String stance) async {
    if (!_useBackend) {
      debugPrint('⚠️  Backend not available, vote not saved');
      throw Exception('Backend not available');
    }

    try {
      debugPrint('🗳️  Voting on policy $policyId with stance: $stance');
      
      // Get device ID
      final deviceId = await DeviceService.getDeviceId();
      
      // Cast vote with device ID
      await _api.castVote(int.parse(policyId), stance, deviceId);
      
      debugPrint('✅ Vote submitted successfully');
      
      // Refresh policies to get updated vote counts
      await fetchPoliciesFromBackend();
      
    } catch (e) {
      debugPrint('❌ Error voting: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ✅ NEW: Withdraw vote
  Future<void> withdrawVote(String policyId) async {
    if (!_useBackend) {
      debugPrint('⚠️  Backend not available');
      throw Exception('Backend not available');
    }

    try {
      debugPrint('🗑️  Withdrawing vote from policy $policyId');
      
      // Get device ID
      final deviceId = await DeviceService.getDeviceId();
      
      // Delete vote
      await _api.deleteVote(int.parse(policyId), deviceId);
      
      debugPrint('✅ Vote withdrawn successfully');
      
      // Refresh policies
      await fetchPoliciesFromBackend();
      
    } catch (e) {
      debugPrint('❌ Error withdrawing vote: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Check if user already voted
  Future<Map<String, dynamic>> checkMyVote(String policyId) async {
    if (!_useBackend) {
      return {'voted': false, 'stance': null};
    }

    try {
      final deviceId = await DeviceService.getDeviceId();
      final result = await _api.getMyVote(int.parse(policyId), deviceId);
      
      debugPrint('✅ My Vote Status: ${result['voted']} - ${result['stance']}');
      return result;
      
    } catch (e) {
      debugPrint('❌ Error checking vote: $e');
      return {'voted': false, 'stance': null};
    }
  }

  /// Get vote results
  Future<Map<String, dynamic>?> getVoteResults(String policyId) async {
    if (!_useBackend) {
      return null;
    }

    try {
      final results = await _api.getVoteResults(int.parse(policyId));
      debugPrint('✅ Vote Results: $results');
      return results;
      
    } catch (e) {
      debugPrint('❌ Error getting results: $e');
      return null;
    }
  }

  /// Switch between mock and backend data
  void toggleDataSource(bool useBackend) {
    _useBackend = useBackend;
    if (useBackend) {
      fetchPoliciesFromBackend();
    }
    notifyListeners();
  }
}
