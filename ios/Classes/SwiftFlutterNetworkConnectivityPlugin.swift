import Flutter
import UIKit
import Foundation
import Network

public class SwiftFlutterNetworkConnectivityPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor = NWPathMonitor()
    
    private var isConnected: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterNetworkConnectivityPlugin()
        
        let channel = FlutterMethodChannel(name: "com.livelifedev.flutter_network_connectivity/network_state", binaryMessenger: registrar.messenger())
        
        let networkEventChannel = FlutterEventChannel(name: "com.livelifedev.flutter_network_connectivity/network_status", binaryMessenger: registrar.messenger())
        
        networkEventChannel.setStreamHandler(instance)
        
        instance.startMonitoring()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isNetworkAvailable":
            result(isConnected)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
                self.eventSink?(true)
            } else {
                self.isConnected = false
                self.eventSink?(false)
            }
            //            self?.isConnected = path.status == .satisfied
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
}
