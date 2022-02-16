import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// [FlutterNetworkConnectivity] checks for network availability
/// Connected to Wifi or Cellular Data - returns true/false
/// true - Connected to Network
/// false - Not Connected to Network

class FlutterNetworkConnectivity {
  /// Method Channel to Check if Network is Available
  /// To check one time call
  static const MethodChannel _methodChannel = MethodChannel(
      'com.livelifedev.flutter_network_connectivity/network_state');

  /// Event Channel to get Stream of Network Status
  static const EventChannel _eventChannel = EventChannel(
      'com.livelifedev.flutter_network_connectivity/network_status');

  /// Checks if Network is Available
  ///
  /// Android call requires permission [android.permission.ACCESS_NETWORK_STATE]
  /// iOS min version required: 12.0
  Future<bool> isNetworkAvailable() async {
    bool hasConnection =
        await _methodChannel.invokeMethod("isNetworkAvailable");
    return hasConnection;
  }

  /// Register Listener to check for Network Stream
  /// Must be unregistered if not in use
  /// registering only on android as iOS makes use of NetworkMonitor
  Future registerNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("registerNetworkStatusListener");
    }
  }

  /// Unregister Listener when not in use
  /// unregister only on android as iOS makes use of NetworkMonitor
  Future unregisterNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("unregisterNetworkStatusListener");
    }
  }

  /// Returns Stream of bool denoting network status
  /// Start Listening on [initState] then proceed to [registerNetworkListener]
  /// true - Network connection is available
  /// false = Network connection is not available
  Stream<bool> getNetworkStatusStream() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }
}
