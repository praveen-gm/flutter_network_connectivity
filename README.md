
# Flutter Network Connectivity

[![Pub](https://img.shields.io/badge/pub-v0.0.4-orange)](https://pub.dev/packages/flutter_network_connectivity)

A Flutter Plugin to check for live network connectivity status via Stream or On Call.

# Usage

First, add `flutter_network_connectivity` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  flutter_network_connectivity: ^0.0.4
```

Don't forget to `flutter pub get`.

Then import:

```dart
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
```

Now you can create FlutterNetworkConnectivity object and use its methods

```
FlutterNetworkConnectivity flutterNetworkConnectivity =
    FlutterNetworkConnectivity();
 ```
### To Check for Stream of Network Connectivity Status
```
_flutterNetworkConnectivity.getNetworkStatusStream().listen((isConnected) {
  // isConnected returns true/false on Network Connectivity Changes
});
```

Then Register Listener after setting up listener

```
await _flutterNetworkConnectivity.registerNetworkListener();
```

Unregister on dispose

```
_flutterNetworkConnectivity.unregisterNetworkListener();
```

### To Check for Current Nnetwork Status on Call

```
bool isNetworkConnected =
    await flutterNetworkConnectivity.isNetworkAvailable();
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

![Screenshot](/screenshots/demo.gif)

### About
This plugin uses [NetworkCapabilities](https://developer.android.com/reference/android/net/NetworkCapabilities) for Android and [NetworkMonitor](https://developer.apple.com/documentation/network) for iOS.


### Contributing?
You're always welcome.
See [Contributing Guidelines](CONTRIBUTING.md). You can also take a look at [Status Tracker](https://github.com/praveen-gm/flutter_network_connectivity/projects/1) to know more information about current or pending features/issues.