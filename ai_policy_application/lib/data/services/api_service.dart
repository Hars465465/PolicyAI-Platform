import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../services/device_service.dart';  // ✅ ADD THIS IMPORT

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _initDio();
  }

  // ✅ REPLACE with your actual IP from ipconfig!
  static const String _localBaseUrl = 'http://192.168.1.13:8000';
  static const String _productionBaseUrl = 'https://policyai-platform-production.up.railway.app';
  
  static String get baseUrl => kDebugMode ? _localBaseUrl : _productionBaseUrl;
  
  late Dio dio;

  void _initDio() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Debug logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('🚀 REQUEST[${options.method}] => ${options.uri}');
          debugPrint('📦 Data: ${options.data}');
          
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          debugPrint('📦 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          debugPrint('💥 Type: ${error.type}');
          debugPrint('💥 Message: ${error.message}');
          debugPrint('💥 Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  // ========== AUTH ==========

  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      debugPrint('📧 Sending OTP to: $email');
      
      final response = await dio.post('/api/auth/email/send-otp', data: {
        'email': email,
      });
      
      debugPrint('✅ OTP Response: ${response.data}');
      
      return {
        'message': response.data['message'] ?? 'OTP sent',
        'mock_otp': response.data['mock_otp']?.toString() ?? 
                   response.data['otp']?.toString() ?? 
                   'Check backend console',
        'email': email,
        'success': true,
      };
      
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');
      debugPrint('❌ Status: ${e.response?.statusCode}');
      debugPrint('❌ Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Cannot connect to backend\n\n'
          'Make sure:\n'
          '1. Backend running: uvicorn main:app --reload --host 0.0.0.0 --port 8000\n'
          '2. Phone and PC on same WiFi\n'
          '3. Can open http://$baseUrl/docs in phone browser'
        );
      } else if (e.response != null) {
        final errorMsg = e.response?.data?['detail'] ?? 
                        e.response?.data?['message'] ?? 
                        'Server error';
        throw Exception(errorMsg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(String email, String otp) async {
    try {
      debugPrint('🔐 Verifying OTP for: $email');
      
      final response = await dio.post(
        '/api/auth/email/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      debugPrint('✅ Verify Response: ${response.data}');
      
      if (response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
      }
      
      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      debugPrint('❌ Verify Error: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data?['detail'] ?? 'Invalid OTP');
      } else if (e.response?.statusCode == 404) {
        throw Exception('OTP expired or not found');
      } else {
        throw Exception(e.response?.data?['detail'] ?? 'Verification failed');
      }
    }
  }

  Future<Map<String, dynamic>> googleSignIn(
    String googleToken,
    String email,
    String name,
    String? avatarUrl,
  ) async {
    try {
      debugPrint('🔐 Google Sign-In: $email');
      
      final response = await dio.post('/api/auth/google/signin', data: {
        'google_token': googleToken,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
      });
      
      if (response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
      }
      
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Google Sign-In Error: ${e.response?.data}');
      throw Exception(e.response?.data?['detail'] ?? 'Sign-in failed');
    }
  }

  // ========== POLICIES ==========

  Future<List<dynamic>> getPolicies() async {
    try {
      final response = await dio.get('/api/policies');
      return response.data;
    } catch (e) {
      debugPrint('❌ Get Policies Error: $e');
      throw Exception('Failed to load policies');
    }
  }

  Future<Map<String, dynamic>> getPolicy(int id) async {
    try {
      final response = await dio.get('/api/policies/$id');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load policy');
    }
  }

  // ✅ Cast vote with device ID
  Future<Map<String, dynamic>> castVote(
    int policyId,
    String stance,
    String deviceId,
  ) async {
    try {
      debugPrint('🗳️ Casting vote: Policy $policyId, Stance: $stance, Device: $deviceId');
      
      final response = await dio.post(
        '/api/policies/$policyId/vote',
        data: {
          'device_id': deviceId,
          'stance': stance,
        },
      );
      
      debugPrint('✅ Vote Response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Vote Error: ${e.response?.data}');
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to cast vote'
      );
    }
  }

  // ✅ Get vote results
  Future<Map<String, dynamic>> getVoteResults(int policyId) async {
    try {
      final response = await dio.get('/api/policies/$policyId/results');
      debugPrint('✅ Vote Results: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Results Error: ${e.response?.data}');
      throw Exception('Failed to get vote results');
    }
  }

  // ✅ Check my vote
  Future<Map<String, dynamic>> getMyVote(int policyId, String deviceId) async {
    try {
      final response = await dio.get(
        '/api/policies/$policyId/my-vote',
        queryParameters: {'device_id': deviceId},
      );
      debugPrint('✅ My Vote: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ My Vote Error: ${e.response?.data}');
      return {'voted': false, 'stance': null};
    }
  }

  // ✅ Delete vote (withdraw)
  Future<void> deleteVote(int policyId, String deviceId) async {
    try {
      debugPrint('🗑️ Deleting vote: Policy $policyId, Device: $deviceId');
      
      final response = await dio.delete(
        '/api/policies/$policyId/vote',
        queryParameters: {'device_id': deviceId},
      );
      
      debugPrint('✅ Vote Deleted: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete vote');
      }
    } on DioException catch (e) {
      debugPrint('❌ Delete Vote Error: ${e.response?.data}');
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to withdraw vote'
      );
    }
  }


  // ========== USER PROFILE ==========

  /// Get user profile with statistics
  Future<Map<String, dynamic>> getUserProfile(String deviceId) async {
    try {
      debugPrint('📊 Fetching user profile for device: $deviceId');
      
      final response = await dio.get(
        '/api/users/me',
        queryParameters: {'device_id': deviceId},
      );
      
      debugPrint('✅ User Profile: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Get Profile Error: ${e.response?.data}');
      throw Exception('Failed to get user profile');
    }
  }

  /// Get voting history
  Future<List<dynamic>> getVotingHistory(String deviceId) async {
    try {
      debugPrint('📜 Fetching voting history for device: $deviceId');
      
      final response = await dio.get(
        '/api/users/me/voting-history',
        queryParameters: {'device_id': deviceId},
      );
      
      debugPrint('✅ Voting History: ${response.data['total']} votes');
      return response.data['votes'];
    } on DioException catch (e) {
      debugPrint('❌ Get History Error: ${e.response?.data}');
      return [];
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      
      debugPrint('✏️ Updating profile for device: $deviceId');
      
      final response = await dio.put(
        '/api/users/me/update',
        queryParameters: {'device_id': deviceId},
        data: {
          if (name != null) 'name': name,
          // bio and avatarUrl not supported yet in backend
        },
      );
      
      debugPrint('✅ Profile Updated: ${response.data}');
      return {'success': true, 'user': response.data['user']};
    } on DioException catch (e) {
      debugPrint('❌ Update Profile Error: ${e.response?.data}');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== COMMENTS METHODS ==========

/// Get all comments for a policy
Future<List<Map<String, dynamic>>> getComments(int policyId, String deviceId, {String sort = 'newest'}) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/policies/$policyId/comments?device_id=$deviceId&sort=$sort'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['comments']);
    } else {
      throw Exception('Failed to load comments');
    }
  } catch (e) {
    debugPrint('❌ Error fetching comments: $e');
    rethrow;
  }
}

/// Add a comment to a policy
Future<Map<String, dynamic>> addComment(int policyId, String text, String deviceId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/policies/$policyId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'device_id': deviceId,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add comment');
    }
  } catch (e) {
    debugPrint('❌ Error adding comment: $e');
    rethrow;
  }
}

/// Delete a comment
Future<bool> deleteComment(int commentId, String deviceId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/comments/$commentId?device_id=$deviceId'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete comment');
    }
  } catch (e) {
    debugPrint('❌ Error deleting comment: $e');
    return false;
  }
}

/// Get comment count for a policy
Future<int> getCommentCount(int policyId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/policies/$policyId/comments/count'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['total_comments'];
    } else {
      return 0;
    }
  } catch (e) {
    debugPrint('❌ Error getting comment count: $e');
    return 0;
  }
}


  // ========== TOKEN MANAGEMENT ==========

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
