import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  /// Get unique device ID
  static Future<String> getDeviceId() async {
    // Check cache first
    if (_cachedDeviceId != null) {
      debugPrint('📱 Using cached device ID: $_cachedDeviceId');
      return _cachedDeviceId!;
    }

    // Check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('device_id');
    if (savedId != null) {
      _cachedDeviceId = savedId;
      debugPrint('📱 Using saved device ID: $_cachedDeviceId');
      return savedId;
    }

    // Generate new device ID
    try {
      String deviceId;
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        debugPrint('📱 Android Device ID: $deviceId');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('📱 iOS Device ID: $deviceId');
      } else {
        // Web or other platforms
        deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('📱 Web Device ID: $deviceId');
      }

      // Save to cache and preferences
      _cachedDeviceId = deviceId;
      await prefs.setString('device_id', deviceId);
      
      return deviceId;
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      
      // Fallback
      final fallbackId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      _cachedDeviceId = fallbackId;
      await prefs.setString('device_id', fallbackId);
      
      return fallbackId;
    }
  }

  /// Clear cached device ID (for testing)
  static Future<void> clearCache() async {
    _cachedDeviceId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_id');
    debugPrint('🗑️ Device ID cache cleared');
  }
}
