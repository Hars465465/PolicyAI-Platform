import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;
  String? _name;
  String? _avatarUrl;
  String? _authProvider; // 'email' or 'google'

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  String? get name => _name;
  String? get avatarUrl => _avatarUrl;
  String? get authProvider => _authProvider;

  // Storage keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'user_email';
  static const String _keyName = 'user_name';
  static const String _keyAvatarUrl = 'user_avatar_url';
  static const String _keyAuthProvider = 'auth_provider';

  /// Load user data from storage (on app start)
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _email = prefs.getString(_keyEmail);
    _name = prefs.getString(_keyName);
    _avatarUrl = prefs.getString(_keyAvatarUrl);
    _authProvider = prefs.getString(_keyAuthProvider);
    notifyListeners();
  }

  /// Login with email or Google
  Future<void> login({
    required String email,
    String? name,
    String? avatarUrl,
    String provider = 'email',
  }) async {
    _isLoggedIn = true;
    _email = email;
    _name = name;
    _avatarUrl = avatarUrl;
    _authProvider = provider;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, email);
    if (name != null) await prefs.setString(_keyName, name);
    if (avatarUrl != null) await prefs.setString(_keyAvatarUrl, avatarUrl);
    await prefs.setString(_keyAuthProvider, provider);

    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    if (name != null) _name = name;
    if (avatarUrl != null) _avatarUrl = avatarUrl;

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyName, name);
    if (avatarUrl != null) await prefs.setString(_keyAvatarUrl, avatarUrl);

    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _email = null;
    _name = null;
    _avatarUrl = null;
    _authProvider = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyAvatarUrl);
    await prefs.remove(_keyAuthProvider);

    notifyListeners();
  }

  /// Display name (email or name)
  String get displayName => _name ?? _email ?? 'User';

  /// Display email (fallback to "Not provided")
  String get displayEmail => _email ?? 'No email';

  /// Check if user has completed profile
  bool get hasCompletedProfile => _name != null && _name!.isNotEmpty;
}
