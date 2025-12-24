import 'package:flutter/foundation.dart';
import '../models/policy.dart';
import '../data/services/api_service.dart';

class PolicyProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Mock data as fallback
  List<Policy> _allPolicies = [
    Policy(
      id: '1',
      title: 'National Education Reform Act 2025',
      description:
          'Comprehensive education system overhaul focusing on digital literacy, skill development, and equal access to quality education across urban and rural areas.',
      category: 'Education',
      supportPercentage: 68,
      opposePercentage: 32,
      totalVotes: '45.2K',
      timeLeft: '5 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Policy(
      id: '2',
      title: 'Universal Healthcare Access Program',
      description:
          'Initiative to provide free primary healthcare services to all citizens through expanded public health infrastructure and telemedicine integration.',
      category: 'Healthcare',
      supportPercentage: 72,
      opposePercentage: 28,
      totalVotes: '52.8K',
      timeLeft: '3 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Policy(
      id: '3',
      title: 'Green Energy Infrastructure Plan',
      description:
          'Nationwide transition to renewable energy sources with solar panel subsidies, wind farms, and electric vehicle charging network expansion.',
      category: 'Infrastructure',
      supportPercentage: 65,
      opposePercentage: 35,
      totalVotes: '38.9K',
      timeLeft: '7 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Policy(
      id: '4',
      title: 'Digital India 2.0 Initiative',
      description:
          'Accelerate digital transformation with 5G rollout, cybersecurity framework, and digital skills training for 10 million citizens.',
      category: 'Technology',
      supportPercentage: 78,
      opposePercentage: 22,
      totalVotes: '61.4K',
      timeLeft: '4 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Policy(
      id: '5',
      title: 'Agricultural Modernization Scheme',
      description:
          'Support farmers with modern equipment subsidies, direct market access platforms, and crop insurance reforms to boost rural income.',
      category: 'Agriculture',
      supportPercentage: 70,
      opposePercentage: 30,
      totalVotes: '42.1K',
      timeLeft: '6 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Policy(
      id: '6',
      title: 'Urban Housing Development Act',
      description:
          'Affordable housing scheme with low-interest loans, rent control measures, and infrastructure development in tier-2 and tier-3 cities.',
      category: 'Housing',
      supportPercentage: 63,
      opposePercentage: 37,
      totalVotes: '36.7K',
      timeLeft: '8 days left',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _useBackend = false;  // Toggle between mock and backend

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
      return _allPolicies.firstWhere((policy) => policy.id == id);
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
      final data = await _api.getPolicies();
      
      _allPolicies = data.map((json) => Policy(
        id: json['id'].toString(),
        title: json['title'],
        description: json['description'],
        category: json['category'],
        supportPercentage: json['support_percentage'],
        opposePercentage: json['oppose_percentage'],
        totalVotes: json['total_votes'].toString(),
        timeLeft: json['time_left'],
        createdAt: DateTime.now(),  // Can parse from json if available
      )).toList();
      
      _useBackend = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _useBackend = false;  // Fall back to mock data
      notifyListeners();
      
      if (kDebugMode) {
        print('Error fetching from backend: $e');
        print('Using mock data as fallback');
      }
    }
  }

  /// Vote on a policy (backend)
  Future<void> voteOnPolicy(String policyId, String stance) async {
    if (!_useBackend) {
      if (kDebugMode) {
        print('Backend not available, vote not saved');
      }
      return;
    }

    try {
      await _api.vote(int.parse(policyId), stance);
      
      // Refresh policies to get updated vote counts
      await fetchPoliciesFromBackend();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        print('Error voting: $e');
      }
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
