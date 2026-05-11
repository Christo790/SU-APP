import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static late Map<String, dynamic> _deviceData;

  static Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        _deviceData = _readAndroidDeviceInfo(await _deviceInfoPlugin.androidInfo);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        _deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        _deviceData = _readWindowsDeviceInfo(await _deviceInfoPlugin.windowsInfo);
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        _deviceData = _readLinuxDeviceInfo(await _deviceInfoPlugin.linuxInfo);
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        _deviceData = _readMacOsDeviceInfo(await _deviceInfoPlugin.macOsInfo);
      } else if (kIsWeb) {
        // Web platform - generate a persistent device ID
        String webDeviceId;
        final prefs = await _getPrefsSafe();
        if (prefs != null) {
          webDeviceId = prefs.getString('web_device_id') ?? '';
          if (webDeviceId.isEmpty) {
            webDeviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
            await prefs.setString('web_device_id', webDeviceId);
          }
        } else {
          webDeviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
        }
        _deviceData = {
          'platform': 'Web',
          'deviceId': webDeviceId,
        };
      } else {
        _deviceData = {
          'platform': defaultTargetPlatform.toString(),
          'error': 'Unknown platform',
        };
      }
    } catch (e) {
      _deviceData = {'error': e.toString()};
    }
  }

  static Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
    return {
      'platform': 'Android',
      'device': info.device,
      'model': info.model,
      'manufacturer': info.manufacturer,
      'brand': info.brand,
      'product': info.product,
      'deviceId': info.id,
      'board': info.board,
      'hardware': info.hardware,
      'sdkVersion': info.version.sdkInt,
      'osVersion': info.version.release,
      'incremental': info.version.incremental,
      'securityPatch': info.version.securityPatch,
      'buildId': info.version.baseOS,
      'support64Bit': info.supported64BitAbis,
      'support32Bit': info.supported32BitAbis,
      'supportAbis': info.supportedAbis,
      'display': info.display,
      'systemFeatures': info.systemFeatures.toList(),
      'isPhysicalDevice': info.isPhysicalDevice,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
    return {
      'platform': 'iOS',
      'device': info.name,
      'model': info.model,
      'systemName': info.systemName,
      'systemVersion': info.systemVersion,
      'identifierForVendor': info.identifierForVendor,
      'isPhysicalDevice': info.isPhysicalDevice,
      'localizedModel': info.localizedModel,
      'utsname': {
        'sysname': info.utsname.sysname,
        'nodename': info.utsname.nodename,
        'release': info.utsname.release,
        'version': info.utsname.version,
        'machine': info.utsname.machine,
      },
    };
  }

  static Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo info) {
    return {
      'platform': 'Windows',
      'computerName': info.computerName,
      'numberOfCores': info.numberOfCores,
      'systemMemoryInMegabytes': info.systemMemoryInMegabytes,
      'userName': info.userName,
      'majorVersion': info.majorVersion,
      'minorVersion': info.minorVersion,
      'buildNumber': info.buildNumber,
      'productName': info.productName,
      'productType': info.productType,
    };
  }

  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo info) {
    return {
      'platform': 'Linux',
      'id': info.id,
      'name': info.name,
      'version': info.version,
      'prettyName': info.prettyName,
      'buildId': info.buildId,
      'variantId': info.variantId,
      'variant': info.variant,
      'machineId': info.machineId,
    };
  }

  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo info) {
    return {
      'platform': 'macOS',
      'computerName': info.computerName,
      'hostName': info.hostName,
      'arch': info.arch,
      'model': info.model,
      'kernelVersion': info.kernelVersion,
      'osRelease': info.osRelease,
      'activeCPUs': info.activeCPUs,
      'memorySize': info.memorySize,
    };
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_deviceData.isEmpty) {
      await initialize();
    }
    return _deviceData;
  }

  static Future<Map<String, String>> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'buildSignature': packageInfo.buildSignature,
    };
  }

  static Future<Map<String, dynamic>> getFullDeviceInfo() async {
    final deviceInfo = await getDeviceInfo();
    final appInfo = await getAppInfo();
    final fullInfo = {
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return fullInfo;
  }
}
