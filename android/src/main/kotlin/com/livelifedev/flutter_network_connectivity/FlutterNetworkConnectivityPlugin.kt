package com.livelifedev.flutter_network_connectivity

import android.content.Context
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.livelifedev.flutter_network_connectivity.utils.FlutterNetworkConnectivity
import com.livelifedev.flutter_network_connectivity.utils.isNetworkAvailable
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterNetworkConnectivityPlugin */
class FlutterNetworkConnectivityPlugin : FlutterPlugin, MethodCallHandler,
    EventChannel.StreamHandler, FlutterNetworkConnectivity.ConnectivityListener {


    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel


    /// Context initialized onAttachedToEngine
    /// Required to access SystemService
    private lateinit var context: Context


    /// ConnectivityManager for API Level 24 and above
    /// Needs to be unregistered on destroy
    private lateinit var connectivityManager: ConnectivityManager


    /// FlutterNetworkConnectivity for API LEVEL 23 and below
    /// Needs to be unregistered on destroy
    private lateinit var flutterNetworkConnectivity: FlutterNetworkConnectivity

    /// EventSink to Stream Network Status back
    private var eventSink: EventChannel.EventSink? = null

    /// eventSink Response to be called on UI thread
    /// ConnectivityManager.NetworkCallback runs on ConnectivityManager Thread
    /// Connectivity Manager needs Android VERSION 21 and above
    private val uiThreadHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.livelifedev.flutter_network_connectivity/network_state"
        )
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "com.livelifedev.flutter_network_connectivity/network_status"
        )
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isNetworkAvailable" -> result.success(isNetworkAvailable(context))
            "registerNetworkStatusListener" -> startNetworkStatusListener()
            "unregisterNetworkStatusListener" -> stopNetworkStatusListener()
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)

        stopNetworkStatusListener()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }

    @Suppress("Deprecation")
    private fun startNetworkStatusListener() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (!this::connectivityManager.isInitialized) {
                connectivityManager = context.getSystemService(ConnectivityManager::class.java)
            }

            connectivityManager.registerDefaultNetworkCallback(networkCallback)
        } else {
            if (!this::flutterNetworkConnectivity.isInitialized) {
                flutterNetworkConnectivity = FlutterNetworkConnectivity()
            }

            flutterNetworkConnectivity.setConnectivityListener(this)

            context.registerReceiver(
                flutterNetworkConnectivity,
                IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
            )
        }
    }

    private fun stopNetworkStatusListener() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (this::connectivityManager.isInitialized) {
                connectivityManager.unregisterNetworkCallback(networkCallback)
            }
        } else {
            if (this::flutterNetworkConnectivity.isInitialized) {
                context.unregisterReceiver(flutterNetworkConnectivity)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private val networkCallback =
        object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                uiThreadHandler.post {
                    eventSink?.success(true)
                }
            }

            override fun onLost(network: Network) {
                uiThreadHandler.post {
                    eventSink?.success(false)
                }
            }
        }

    override fun onNetworkConnectionChanged(isConnected: Boolean) {
        eventSink?.success(isConnected)
    }

}
