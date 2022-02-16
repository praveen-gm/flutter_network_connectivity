package com.livelifedev.flutter_network_connectivity.utils

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class FlutterNetworkConnectivity : BroadcastReceiver() {

    private var connectivityListener: ConnectivityListener? = null

    override fun onReceive(context: Context?, intent: Intent?) {
        connectivityListener?.onNetworkConnectionChanged(
            isNetworkAvailable(context!!)
        )
    }

    fun setConnectivityListener(connectivityListener: ConnectivityListener) {
        this.connectivityListener = connectivityListener
    }

    interface ConnectivityListener {
        fun onNetworkConnectionChanged(isConnected: Boolean)
    }

}