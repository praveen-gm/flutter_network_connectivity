# Flutter Network Connectivity

[![Pub](https://img.shields.io/badge/pub-v0.0.1-orange)](https://pub.dev/packages/flutter_network_connectivity)

A Flutter Plugin to check network status.

# Usage

First, add `flutter_network_connectivity` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  flutter_network_connectivity: ^0.0.1
```

Don't forget to `flutter pub get`.

Then import:

``` dart
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
```

Now you can create FlutterNetworkConnectivity object and use its methods

```
FlutterNetworkConnectivity flutterNetworkConnectivity =
    FlutterNetworkConnectivity();
 ```

Check for current network status:
```
bool isNetworkConnected =
    await flutterNetworkConnectivity.isNetworkAvailable();
```


### Examples
Simple usage example can be found [in the example folder](example/lib/main.dart).


**Android**
Uses permission

```
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**iOS**
Uses NetworkMonitor, minimum required version 12.0


### About
This plugin uses [NetworkCapabilities](https://developer.android.com/reference/android/net/NetworkCapabilities) for Android and [NetworkMonitor](https://developer.apple.com/documentation/network) for iOS.

### Todo

 There are few things left to implement:

 - Stream of Network Changes (currently working on..)
 - Web Implementation

### Contributing?
You're always welcome.
See [Contributing Guidelines](CONTRIBUTING.md). You can also take a look at [Status Tracker](https://github.com/praveen-gm/flutter_network_connectivity/projects/1) to know more information about current or pending features/issues.