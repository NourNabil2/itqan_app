// lib/services/time_validation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class TimeValidationService {
  static const String _lastValidTimeKey = 'last_valid_time';
  static const String _bootTimeKey = 'device_boot_time';
  static const String _lastSyncKey = 'last_time_sync';

  // استخدام multiple time APIs للتأكد
  static const List<String> timeApis = [
    'https://worldtimeapi.org/api/timezone/Etc/UTC',
    'http://worldclockapi.com/api/json/utc/now',
  ];

  // الحصول على الوقت الحقيقي من الـ server
  Future<DateTime?> getServerTime() async {
    for (String api in timeApis) {
      try {
        final response = await http.get(
          Uri.parse(api),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Parse based on API
          if (api.contains('worldtimeapi')) {
            return DateTime.parse(data['utc_datetime']);
          } else if (api.contains('worldclockapi')) {
            return DateTime.parse(data['currentDateTime']);
          }
        }
      } catch (e) {
        continue; // Try next API
      }
    }
    return null;
  }

  // التحقق من صحة وقت الجهاز
  Future<bool> validateDeviceTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // 1. Check if we have internet - try to get server time
      final serverTime = await getServerTime();
      if (serverTime != null) {
        // حفظ الوقت الصحيح
        await _saveValidTime(serverTime);

        // Check if device time is manipulated (more than 5 minutes difference)
        final difference = now.difference(serverTime).abs();
        if (difference.inMinutes > 5) {
          return false; // Device time is manipulated
        }
        return true;
      }

      // 2. No internet - check against last valid time
      final lastValidTimeStr = prefs.getString(_lastValidTimeKey);
      if (lastValidTimeStr != null) {
        final lastValidTime = DateTime.parse(lastValidTimeStr);

        // الوقت الحالي يجب أن يكون بعد آخر وقت صحيح
        if (now.isBefore(lastValidTime)) {
          return false; // Time went backwards - manipulation detected
        }

        // Check boot time consistency
        final isBootTimeValid = await _validateBootTime();
        if (!isBootTimeValid) {
          return false;
        }
      }

      return true;
    } catch (e) {
      // If validation fails, assume time might be manipulated
      return false;
    }
  }

  // حفظ آخر وقت صحيح
  Future<void> _saveValidTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastValidTimeKey, time.toIso8601String());
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // التحقق من boot time
  Future<bool> _validateBootTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Get device uptime (time since boot)
      final uptime = await _getDeviceUptime();
      if (uptime == null) return true; // Can't validate, allow

      final bootTime = now.subtract(uptime);

      final savedBootTimeStr = prefs.getString(_bootTimeKey);
      if (savedBootTimeStr != null) {
        final savedBootTime = DateTime.parse(savedBootTimeStr);

        // Boot time shouldn't be before saved boot time (device wasn't rebooted)
        // Allow 1 minute tolerance
        if (bootTime.difference(savedBootTime).abs().inMinutes > 1) {
          // Device was rebooted or time manipulated
          await prefs.setString(_bootTimeKey, bootTime.toIso8601String());
        }
      } else {
        await prefs.setString(_bootTimeKey, bootTime.toIso8601String());
      }

      return true;
    } catch (e) {
      return true; // Allow if can't validate
    }
  }

  // Get device uptime using platform channel
  Future<Duration?> _getDeviceUptime() async {
    try {
      const platform = MethodChannel('com.itqangym/time_validation');
      final uptime = await platform.invokeMethod<int>('getUptime');
      if (uptime != null) {
        return Duration(milliseconds: uptime);
      }
    } catch (e) {
      // Platform channel not implemented
    }
    return null;
  }

  // Check if subscription is expired (with time validation)
  Future<bool> isSubscriptionValid(DateTime? expiredDate) async {
    if (expiredDate == null) return false;

    // First validate device time
    final isTimeValid = await validateDeviceTime();
    if (!isTimeValid) {
      return false; // Time manipulation detected
    }

    // Use validated time
    return DateTime.now().isBefore(expiredDate);
  }

  // Clear validation data (on logout)
  Future<void> clearValidationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastValidTimeKey);
    await prefs.remove(_bootTimeKey);
    await prefs.remove(_lastSyncKey);
  }
}