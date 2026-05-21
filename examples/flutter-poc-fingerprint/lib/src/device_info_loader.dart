import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_web/web.dart' as web;

import 'models.dart';
import 'referral_info_loader.dart';

class DeviceInfoLoader {
  DeviceInfoLoader({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  Future<DeviceSnapshot> load(BuildContext context) async {
    final referral = loadReferralParams(
      kIsWeb ? Uri.parse(web.window.location.href) : Uri.base,
    );
    final source = _source;
    final device = await _deviceMap(context, source);
    final fingerprintInput = buildFingerprintInput(device);
    final fingerprint = buildFingerprint(fingerprintInput);

    return DeviceSnapshot(
      fingerprint: fingerprint,
      fingerprintInput: fingerprintInput,
      collectedAt: DateTime.now(),
      source: source,
      device: device,
      referral: referral,
    );
  }

  String get _source {
    if (kIsWeb) return 'flutter-web';
    if (Platform.isAndroid) return 'flutter-android';
    if (Platform.isIOS) return 'flutter-ios';
    return 'flutter-other';
  }

  Future<T> _withDeviceInfoTimeout<T>(Future<T> future) {
    return future.timeout(const Duration(seconds: 3));
  }

  Future<Map<String, Object?>> _deviceMap(
      BuildContext context, String source) async {
    final mediaQuery = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);
    final base = <String, Object?>{
      'appRuntime': source,
      'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
      'screen': mediaQuery == null
          ? null
          : '${mediaQuery.size.width.toStringAsFixed(0)}x${mediaQuery.size.height.toStringAsFixed(0)}',
      'devicePixelRatio': view?.devicePixelRatio,
      'colorScheme': mediaQuery?.platformBrightness.name,
      'ipAddress': 'Unavailable without a same-origin backend endpoint',
    };

    try {
      if (kIsWeb) {
        final info = await _withDeviceInfoTimeout(_plugin.webBrowserInfo);
        final navigator = web.window.navigator;
        final screen = web.window.screen;
        final userAgent = navigator.userAgent;
        return {
          ...base,
          'platform': 'web',
          'platformVersion': userAgent,
          'browserName': info.browserName.name,
          'browserVersion': userAgent,
          'userAgent': userAgent,
          'locale': navigator.language,
          'screen': '${screen.width}x${screen.height}',
          'devicePixelRatio': web.window.devicePixelRatio,
          'colorScheme':
              web.window.matchMedia('(prefers-color-scheme: dark)').matches
                  ? 'dark'
                  : 'light',
          'vendor': info.vendor,
          'hardwareConcurrency': navigator.hardwareConcurrency,
        };
      }

      if (Platform.isAndroid) {
        final info = await _withDeviceInfoTimeout(_plugin.androidInfo);
        return {
          ...base,
          'platform': 'android',
          'platformVersion': info.version.release,
          'manufacturer': info.manufacturer,
          'model': info.model,
          'sdkInt': info.version.sdkInt,
          'isPhysicalDevice': info.isPhysicalDevice,
        };
      }

      if (Platform.isIOS) {
        final info = await _withDeviceInfoTimeout(_plugin.iosInfo);
        return {
          ...base,
          'platform': 'ios',
          'platformVersion': info.systemVersion,
          'manufacturer': 'Apple',
          'model': info.utsname.machine,
          'systemName': info.systemName,
          'isPhysicalDevice': info.isPhysicalDevice,
        };
      }
    } catch (_) {
      return {
        ...base,
        'platform': source,
        'platformVersion': null,
        'model': null,
        'deviceInfoStatus': 'unavailable',
      };
    }

    return {
      ...base,
      'platform': 'other',
      'platformVersion': null,
      'model': null,
    };
  }
}
