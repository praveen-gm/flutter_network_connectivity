import 'package:flutter/services.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel(
      'com.livelifedev.flutter_network_connectivity/network_state');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isNetworkAvailable', () async {
    expect(await FlutterNetworkConnectivity().isNetworkAvailable(), true);
  });
}
