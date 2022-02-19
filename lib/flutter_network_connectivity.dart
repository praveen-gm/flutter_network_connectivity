import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// [FlutterNetworkConnectivity] checks for network availability
/// Connected to Wifi or Cellular Data - returns true/false
/// true - Connected to Network
/// false - Not Connected to Network

class FlutterNetworkConnectivity {
  static const _defaultLookUpUrl = 'example.com';

  final Duration _defaultDuration = const Duration(seconds: 5);

  /// Method Channel to Check if Network is Available
  /// To check one time call
  static const MethodChannel _methodChannel = MethodChannel(
      'com.livelifedev.flutter_network_connectivity/network_state');

  /// Event Channel to get Stream of Network Status
  static const EventChannel _eventChannel = EventChannel(
      'com.livelifedev.flutter_network_connectivity/network_status');

  /// URL to lookup for to check network connection availability
  late String _lookUpUrl;

  /// set to true in constructor to lookup in a regular interval
  late bool _isContinousLookUp;

  /// override default lookup duration in constructor params
  late Duration _lookUpDuration;

  /// check if internet is available using this bool
  bool isInternetAvailable = false;

  /// stream resulting true/false based on connectivity changes,
  /// lookup on interval if [_isContinousLookUp] is set true
  late StreamController<bool> _internetAvailabilityStreamController;

  /// timer to handle continous look up if [_isContinousLookUp] is set true
  Timer? _timer;

  FlutterNetworkConnectivity(
      {String? lookUpUrl,
      bool isContinousLookUp = false,
      Duration? lookUpDuration}) {
    _internetAvailabilityStreamController = StreamController<bool>();

    _lookUpUrl = lookUpUrl ?? _defaultLookUpUrl;
    _isContinousLookUp = isContinousLookUp;
    _lookUpDuration = lookUpDuration ?? _defaultDuration;

    if (_isContinousLookUp) {
      _startContinousLookUp();
    }
  }

  /// Get Internet Availability Stream based on config's
  /// Default Config: Get Stream on Connectivity Status Change
  /// Available Config's: (to be configured in constructor while object creation)
  /// 1. Set Internet Availability on Period Check [isContinousLookUp] in constructor, default is false
  /// 2. Duration of the Period Check, [lookUpDuration] from constructor, default is [_defaultDuration]
  /// 3. Custom Url to Look Up, [lookUpUrl] from constructor, default is [_defaultLookUpUrl]
  Stream<bool> getInternetAvailabilityStream() {
    return _internetAvailabilityStreamController.stream;
  }

  /// Registers Network Connectivity Listener from Native
  Future registerAvailabilityListener() async {
    /// Listen for Network Connectivity Status
    _getNetworkConnectivityStatusStream().listen((isNetworkConnected) {
      _checkConnection();
    });

    await _registerNetworkConnectivityListener();
    await _checkConnection();
  }

  /// Unregister to cancel timer if set,
  /// close connection listeners from native calls
  Future unregisterAvailabilityListener() async {
    _timer?.cancel();
    await _unregisterNetworkConnectivityListener();
  }

  /// Checks if Network is Available
  ///
  /// Android call requires permission [android.permission.ACCESS_NETWORK_STATE]
  /// iOS min version required: 12.0
  /// deprecation due to renaming of method, replacement method
  /// [isNetworkConnectionAvailable]
  @Deprecated(
      'This Method will be deprecated on the next release, use isNetworkConnectionAvailable instead')
  Future<bool> isNetworkAvailable() async {
    bool hasConnection =
        await _methodChannel.invokeMethod("isNetworkAvailable");
    return hasConnection;
  }

  /// Checks if Network is Available
  ///
  /// Android call requires permission [android.permission.ACCESS_NETWORK_STATE]
  /// iOS min version required: 12.0
  Future<bool> isNetworkConnectionAvailable() async {
    bool hasConnection =
        await _methodChannel.invokeMethod("isNetworkAvailable");
    return hasConnection;
  }

  /// Register Listener to check for Network Stream
  /// Must be unregistered if not in use
  /// registering only on android as iOS makes use of NetworkMonitor
  @Deprecated(
      'This Method will be deprecated on the next release, use registerConnectivityListener instead')
  Future registerNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("registerNetworkStatusListener");
    }
  }

  /// Unregister Listener when not in use
  /// unregister only on android as iOS makes use of NetworkMonitor
  @Deprecated(
      'This method will be deprecated on the next release, use unregisterListener instead')
  Future unregisterNetworkListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("unregisterNetworkStatusListener");
    }
  }

  /// Internally register connectivity change listener
  /// only on android
  Future _registerNetworkConnectivityListener() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod("registerNetworkStatusListener");
    }
  }

  /// Internally unregister connectivity change listener
  /// only on android
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

  /// Platform connectivity status stream from native
  Stream<bool> _getNetworkConnectivityStatusStream() {
    return _eventChannel.receiveBroadcastStream().cast<bool>();
  }

  /// Helper to for connection check
  Future _checkConnection() async {
    isInternetAvailable = await isInternetConnectionAvailable();
    _updateStreamController(isInternetAvailable);
  }

  /// use this method to check to check for internet connection availability
  /// also used on internal methods on periodic/connection status changed
  /// override [_lookUpUrl] on constructor while object creation
  Future<bool> isInternetConnectionAvailable() async {
    try {
      final result = await InternetAddress.lookup(_lookUpUrl);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isInternetAvailable = true;
        _updateStreamController(true);
      } else {
        isInternetAvailable = false;
        _updateStreamController(false);
      }
    } on SocketException catch (_) {
      isInternetAvailable = false;
      _updateStreamController(false);
    }

    return isInternetAvailable;
  }

  /// Helper to update internet status to stream
  _updateStreamController(bool value) {
    _internetAvailabilityStreamController.add(value);
  }

  /// Starts period check if [_isContinousLookUp] is true from constructor
  void _startContinousLookUp() {
    _timer = Timer.periodic(_lookUpDuration, (timer) {
      isInternetConnectionAvailable();
    });
  }
}
