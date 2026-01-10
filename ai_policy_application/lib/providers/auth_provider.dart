import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _avatarUrl;
  String? _authToken;
  String? _authProvider;
  int? _userId;  // ✅ ADD THIS

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _userEmail;
  String? get name => _userName;
  String? get avatarUrl => _avatarUrl;
  String? get authToken => _authToken;
  String? get authProvider => _authProvider;
  int? get userId => _userId;  // ✅ ADD THIS
  
  // ✅ The getter we added earlier
  bool get isAuthenticated => _isLoggedIn && _userEmail != null;

  // Storage keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'user_email';
  static const String _keyName = 'user_name';
  static const String _keyAvatarUrl = 'user_avatar_url';
  static const String _keyAuthProvider = 'auth_provider';
  static const String _keyUserId = 'user_id';  // ✅ ADD THIS

  /// Load user data from storage (on app start)
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _userEmail = prefs.getString(_keyEmail);
    _userName = prefs.getString(_keyName);
    _avatarUrl = prefs.getString(_keyAvatarUrl);
    _authProvider = prefs.getString(_keyAuthProvider);
    _userId = prefs.getInt(_keyUserId);  // ✅ ADD THIS
    notifyListeners();
  }

  /// Login with email or Google
  Future<void> login({
    required String email,
    required String name,
    String? token,
    int? userId,  // ✅ ADD THIS PARAMETER
  }) async {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    _authToken = token;
    _userId = userId;  // ✅ ADD THIS

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    if (token != null) {
      await prefs.setString('authToken', token);
    }
    
    if (userId != null) {
      await prefs.setInt('userId', userId);  // ✅ ADD THIS
    }

    print('✅ User logged in: $name ($email) - ID: $userId');
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _authToken = null;
    _userId = null;  // ✅ ADD THIS

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    print('✅ User logged out');
    notifyListeners();
  }

  // Load saved auth state
  Future<void> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _authToken = prefs.getString('authToken');
    _userId = prefs.getInt('userId');  // ✅ ADD THIS
    
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    if (name != null) _userName = name;
    if (avatarUrl != null) _avatarUrl = avatarUrl;

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyName, name);
    if (avatarUrl != null) await prefs.setString(_keyAvatarUrl, avatarUrl);

    notifyListeners();
  }

  /// Display name (email or name)
  String get displayName => _userName ?? _userEmail ?? 'User';

  /// Display email (fallback to "Not provided")
  String get displayEmail => _userEmail ?? 'No email';

  /// Check if user has completed profile
  bool get hasCompletedProfile => _userName != null && _userName!.isNotEmpty;
}
