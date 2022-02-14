import Flutter
import UIKit

public class SwiftFlutterNetworkConnectivityPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.livelifedev.flutter_network_connectivity/network_state", binaryMessenger: registrar.messenger())
        
        let instance = SwiftFlutterNetworkConnectivityPlugin()
        
        NetworkMonitor.shared.startMonitoring()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isNetworkAvailable":
            result(NetworkMonitor.shared.isConnected)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
