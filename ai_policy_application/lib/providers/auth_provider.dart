import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _phoneNumber;

  bool get isLoggedIn => _isLoggedIn;
  String? get phoneNumber => _phoneNumber; // Add this getter

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPhoneNumber = 'phone_number';

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _phoneNumber = prefs.getString(_keyPhoneNumber);
    notifyListeners();
  }

  Future<void> loginWithPhone(String phone) async {
    _phoneNumber = phone;
    notifyListeners();
  }

  Future<void> verifyOtp(String otp) async {
    // In Phase 1, any 6-digit OTP works
    if (otp.length == 6) {
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyPhoneNumber, _phoneNumber ?? '');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _phoneNumber = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhoneNumber);
    notifyListeners();
  }
}
