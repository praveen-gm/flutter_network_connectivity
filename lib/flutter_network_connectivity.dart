
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNetworkConnectivity {
  static const MethodChannel _channel = MethodChannel('flutter_network_connectivity');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
