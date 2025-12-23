import 'package:flutter/foundation.dart';
import '../models/policy.dart';

class PolicyProvider with ChangeNotifier {
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
}
