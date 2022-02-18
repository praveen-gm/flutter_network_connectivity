import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// [FlutterNetworkConnectivity] checks for network availability
/// Connected to Wifi or Cellular Data - returns true/false
/// true - Connected to Network
/// false - Not Connected to Network

class FlutterNetworkConnectivity {
  static const _defaultLookUpUrl = 'example.com';

  /// Method Channel to Check if Network is Available
  /// To check one time call
  static const MethodChannel _methodChannel = MethodChannel(
      'com.livelifedev.flutter_network_connectivity/network_state');

  /// Event Channel to get Stream of Network Status
  static const EventChannel _eventChannel = EventChannel(
      'com.livelifedev.flutter_network_connectivity/network_status');

  /// URL to lookup for to check network connection availability
  late String _lookUpUrl;

  /// check if internet is available using this bool
  bool isInternetAvailable = false;

  /// add custom url [lookUpUrl] to lookup instead of [_defaultLookUpUrl]
  FlutterNetworkConnectivity({String? lookUpUrl}) {
    _lookUpUrl = lookUpUrl ?? _defaultLookUpUrl;

    _init();
  }

  /// Registers Network Connectivity Listener from Native
  void _init() async {
    /// Listen for Network Connectivity Status
    _getNetworkConnectivityStatusStream().listen((isNetworkConnected) {
      _checkConnection();
    });

    await _registerNetworkConnectivityListener();
    await _checkConnection();
  }

  Future unregisterListener() async {
    await _unregisterNetworkConnectivityListener();
  }

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
  @Deprecated(
      'This Method will be deprecated on the next release, will be registered internally')
  Future registerNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("registerNetworkStatusListener");
    }
  }

  /// Unregister Listener when not in use
  /// unregister only on android as iOS makes use of NetworkMonitor
  @Deprecated(
      'This method will be deprecated on the next release, will be unregistered internally')
  Future unregisterNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("unregisterNetworkStatusListener");
    }
  }

  Future _registerNetworkConnectivityListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("registerNetworkStatusListener");
    }
  }

  Future _unregisterNetworkConnectivityListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("unregisterNetworkStatusListener");
    }
  }

  /// Returns Stream of bool denoting network status
  /// Start Listening on [initState] then proceed to [registerNetworkListener]
  /// true - Network connection is available
  /// false = Network connection is not available
  @Deprecated('This method will be removed on the next released')
  Stream<bool> getNetworkStatusStream() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }

  Stream<bool> _getNetworkConnectivityStatusStream() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }

  Future _checkConnection() async {
    isInternetAvailable = await isInternetConnectionAvailable();
  }

  Future<bool> isInternetConnectionAvailable() async {
    try {
      final result = await InternetAddress.lookup(_lookUpUrl);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isInternetAvailable = true;
      } else {
        isInternetAvailable = false;
      }
    } on SocketException catch (_) {
      isInternetAvailable = false;
    }

    return isInternetAvailable;
  }
}
