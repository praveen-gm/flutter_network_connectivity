import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
      FlutterNetworkConnectivity();

  bool? _isNetworkConnectedOnCall;

  bool? _isNetworkConnectedStreamStatus;

  StreamSubscription<bool>? _networkConnectionStream;

  @override
  void initState() {
    super.initState();

    _flutterNetworkConnectivity.getNetworkStatusStream().listen((event) {
      _isNetworkConnectedStreamStatus = event;
      setState(() {});
    });

    init();
  }

  @override
  void dispose() {
    _networkConnectionStream?.cancel();

    super.dispose();
  }

  void init() async {
    await _flutterNetworkConnectivity.registerNetworkListener();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _checkNetworkState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      _isNetworkConnectedOnCall =
          await _flutterNetworkConnectivity.isNetworkAvailable();
    } on PlatformException {
      _isNetworkConnectedOnCall = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Network Connectivity'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24.0),
                      const Text(
                        'Live Network Stream Status',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            null == _isNetworkConnectedStreamStatus
                                ? 'Unknown State'
                                : _isNetworkConnectedStreamStatus!
                                    ? "You're Connected to Network"
                                    : "You're Offline",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.lightGreen.shade400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24.0),
                      const Text(
                        'Network Status on Call',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              null == _isNetworkConnectedOnCall
                                  ? 'Unknown State'
                                  : _isNetworkConnectedOnCall!
                                      ? "You're Connected to Network"
                                      : "You're Offline",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 50.0),
                            ElevatedButton(
                              onPressed: _checkNetworkState,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.amberAccent,
                              ),
                              child: const Text(
                                'Check Network State',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
