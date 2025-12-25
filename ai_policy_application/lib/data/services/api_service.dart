import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ✅ UPDATED: Railway Production URL
  static const String baseUrl = 'https://policyai-platform-production.up.railway.app/api';
  
  // For local testing (comment out when deploying)
  // static const String baseUrl = 'http://192.168.1.15:8000/api';  // real device
  // static const String baseUrl = 'http://localhost:8000/api';  // iOS Simulator

  late Dio dio;

  Future<void> init() async {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add token to all requests
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // ========== AUTH ==========

  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      final response = await dio.post('/auth/email/send-otp', data: {
        'email': email,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(String email, String otp) async {
    try {
      final response = await dio.post('/auth/email/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      
      // Save token
      await saveToken(response.data['access_token']);
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> googleSignIn(
    String googleToken,
    String email,
    String name,
    String? avatarUrl,
  ) async {
    try {
      final response = await dio.post('/auth/google/signin', data: {
        'google_token': googleToken,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
      });
      
      // Save token
      await saveToken(response.data['access_token']);
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== POLICIES ==========

  Future<List<dynamic>> getPolicies() async {
    try {
      final response = await dio.get('/policies');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPolicy(int id) async {
    try {
      final response = await dio.get('/policies/$id');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> vote(int policyId, String stance) async {
    try {
      final response = await dio.post('/policies/vote', data: {
        'policy_id': policyId,
        'stance': stance,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
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

  // ========== ERROR HANDLING ==========

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response?.data['detail'] ?? 'Server error';
      } else {
        return 'Network error. Check your connection.';
      }
    }
    return 'Something went wrong';
  }
}
