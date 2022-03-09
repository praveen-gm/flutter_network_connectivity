# Flutter Network Connectivity

[![Pub](https://img.shields.io/badge/pub-v0.0.6-orange)](https://pub.dev/packages/flutter_network_connectivity)

A flutter plugin to check for Internet Availability as a stream based on network connectivity status, periodic interval or on call.

# Usage

First, add `flutter_network_connectivity` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  flutter_network_connectivity: ^0.0.6
```

Don't forget to `flutter pub get`.

Then import:

```dart
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
```

Now you can create FlutterNetworkConnectivity object and use its methods

```dart
FlutterNetworkConnectivity flutterNetworkConnectivity =
    FlutterNetworkConnectivity(
	  isContinousLookUp: true,  // optional, false if you don't want continous lookup
	  lookUpDuration: const Duration(seconds: 5),  // optional, to override default lookup duration
	  lookUpUrl: 'example.com',  // optional, to override default lookup url
	);
```
### To Check for Stream of Network Connectivity Status
```dart
_flutterNetworkConnectivity.getInternetAvailabilityStream().listen((isInternetAvailable) {
  // do something
});
```

Then Register Availability Listener after setting up Stream Listerer

```dart
await _flutterNetworkConnectivity.registerAvailabilityListener();
```

Unregister on dispose

```dart
await _flutterNetworkConnectivity.unregisterAvailabilityListener();
```

### To Check for Internet Availability on Call

```dart
bool _isNetworkConnectedOnCall = await
    _flutterNetworkConnectivity.isInternetConnectionAvailable();
```

### Examples
Simple usage example can be found [in the example folder](example/lib/main.dart).

**Android**

Uses permission

```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Minimum SDK Version 16

**iOS**

Uses NetworkMonitor, minimum required version 12.0


**Demo**

![Screenshot](https://raw.githubusercontent.com/praveen-gm/flutter_network_connectivity/main/screenshots/demo.gif "Sample Gif")

### About
This plugin uses [NetworkCapabilities](https://developer.android.com/reference/android/net/NetworkCapabilities) for Android and [NetworkMonitor](https://developer.apple.com/documentation/network) for iOS to check for network connectivity status.


### Contributing?
You're always welcome. See [Contributing Guidelines](CONTRIBUTING.md). You can also take a look at [Status Tracker](https://github.com/praveen-gm/flutter_network_connectivity/projects/1) to know more information about current or pending features/issues.
