import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su/data/device_info_service.dart';

/// Helper to timeout SharedPreferences.getInstance()
Future<SharedPreferences?> _getPrefsSafe([Duration timeout = const Duration(seconds: 5)]) async {
  try {
    return await Future.any([
      SharedPreferences.getInstance(),
      Future.delayed(timeout, () => throw TimeoutException('timeout')),
    ]);
  } catch (e) {
    return null;
  }
}

class DeviceTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send device and app information to Firestore
  static Future<void> sendDeviceInfo() async {
    debugPrint('🚀 sendDeviceInfo() CALLED');
    try {
      // Get user name from SharedPreferences (if available)
      String userName = 'Anonymous';
      final prefs = await _getPrefsSafe();
      if (prefs != null) {
        userName = prefs.getString('chat_username') ?? 'Anonymous';
      } else {
        debugPrint('⚠️ SharedPreferences timeout, using default');
      }

      debugPrint('🔧 Starting device info send...');
      debugPrint('  User name: $userName');

      // Get full device info (includes timestamp)
      debugPrint('  Getting device info...');
      final fullDeviceInfo = await DeviceInfoService.getFullDeviceInfo();
      debugPrint('  Got device info, checking if empty...');

      debugPrint('  Full device info keys: ${fullDeviceInfo.keys.toList()}');
      debugPrint('  Full device info length: ${fullDeviceInfo.length}');

      if (fullDeviceInfo.isEmpty) {
        debugPrint('⚠️❌ Device info is empty, aborting send');
        return;
      }

      final deviceInfo = fullDeviceInfo['deviceInfo'] ?? {};
      final appInfo = fullDeviceInfo['appInfo'] ?? {};
      final generatedAt = fullDeviceInfo['timestamp'] ?? DateTime.now().toIso8601String();

      debugPrint('  deviceInfo keys: ${deviceInfo.keys.toList()}');
      debugPrint('  appInfo keys: ${appInfo.keys.toList()}');

      // Debug: Check all available ID fields
      debugPrint('  🔍 Available ID fields:');
      debugPrint('    deviceId: ${deviceInfo['deviceId']}');
      debugPrint('    identifierForVendor: ${deviceInfo['identifierForVendor']}');
      debugPrint('    id: ${deviceInfo['id']}');

      // Extract key fields
      final deviceType = deviceInfo['platform'] ?? 'Unknown';
      final deviceName = _extractDeviceName(deviceInfo);
      final appVersion = appInfo['version'] ?? 'Unknown';
      final buildNumber = appInfo['buildNumber'] ?? 'Unknown';
      final packageName = appInfo['packageName'] ?? 'Unknown';

      // Extract unique device ID for identifying existing users
      final deviceId = deviceInfo['deviceId'] ?? deviceInfo['identifierForVendor'] ?? deviceInfo['id'] ?? '';

      // Debug: print what we're about to send
      debugPrint('📱 Sending device info to Firestore:');
      debugPrint('  Name: $userName');
      debugPrint('  Device Type: $deviceType');
      debugPrint('  Device Name: $deviceName');
      debugPrint('  App Version: $appVersion ($buildNumber)');
      debugPrint('  Package: $packageName');
      debugPrint('  Timestamp: $generatedAt');
      debugPrint('  Device ID: $deviceId');

      // Validate key fields
      if (deviceType == 'Unknown' && deviceInfo.isEmpty) {
        debugPrint('⚠️ Warning: deviceInfo appears to be empty or uninitialized');
      }

      // Prepare data for Firestore
      final data = {
        'name': userName,
        'deviceType': deviceType,
        'deviceName': deviceName,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'packageName': packageName,
        'timestamp': DateTime.now(), // When the data was sent to Firestore
        'generatedAt': generatedAt, // When the device info was collected
        'deviceId': deviceId, // Unique device identifier
        'deviceInfo': deviceInfo,
        'appInfo': appInfo,
      };

      // Check if user already exists and update or create accordingly
      debugPrint('📝 Writing to user_signups collection...');
      if (deviceId.isNotEmpty) {
        debugPrint('🔍 Querying for existing user with deviceId: $deviceId');
        final existingDocs = await _firestore
            .collection('user_signups')
            .where('deviceId', isEqualTo: deviceId)
            .limit(1)
            .get();

        debugPrint('  Found ${existingDocs.docs.length} existing documents');

        if (existingDocs.docs.isNotEmpty) {
          // Update existing user
          final existingDocId = existingDocs.docs.first.id;
          await _firestore.collection('user_signups').doc(existingDocId).update(data);
          debugPrint('✅ Updated existing user in Firestore (doc: $existingDocId)');
        } else {
          // Create new user
          await _firestore.collection('user_signups').add(data);
          debugPrint('✅ Created new user in Firestore');
        }
      } else {
        // No device ID, create new document
        debugPrint('⚠️ No deviceId found, creating new document');
        await _firestore.collection('user_signups').add(data);
        debugPrint('✅ Device info sent to Firestore (no device ID, created new)');
      }
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ Error sending device info to Firestore: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't throw - allow app to continue even if tracking fails
    }
  }

  /// Debug method to check device info without sending
  static Future<void> debugPrintDeviceInfo() async {
    try {
      await DeviceInfoService.initialize();
      final fullDeviceInfo = await DeviceInfoService.getFullDeviceInfo();
      debugPrint('🔍 DEBUG: Full Device Info:');
      debugPrint(fullDeviceInfo.toString());
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting device info: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Extract a readable device name based on platform
  static String _extractDeviceName(Map<String, dynamic> deviceInfo) {
    final platform = deviceInfo['platform'];

    switch (platform) {
      case 'Android':
        return deviceInfo['device'] ?? deviceInfo['model'] ?? 'Unknown Android Device';
      case 'iOS':
        return deviceInfo['device'] ?? deviceInfo['model'] ?? 'Unknown iOS Device';
      case 'Windows':
        return deviceInfo['computerName'] ?? 'Unknown Windows Device';
      case 'Linux':
        return deviceInfo['name'] ?? deviceInfo['prettyName'] ?? 'Unknown Linux Device';
      case 'macOS':
        return deviceInfo['computerName'] ?? 'Unknown macOS Device';
      default:
        return deviceInfo['device'] ?? deviceInfo['computerName'] ?? 'Unknown Device';
    }
  }
}
