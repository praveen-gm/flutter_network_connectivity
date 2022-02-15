import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNetworkConnectivity {
  static const MethodChannel _methodChannel = MethodChannel(
      'com.livelifedev.flutter_network_connectivity/network_state');

  /// Checks if Network is Available
  ///
  /// Android call requires permission [android.permission.ACCESS_NETWORK_STATE]
  /// iOS min version required: 12.0
  Future<bool> isNetworkAvailable() async {
    bool hasConnection =
        await _methodChannel.invokeMethod("isNetworkAvailable");
    return hasConnection;
  }
}
