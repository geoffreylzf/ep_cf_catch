package my.com.engpeng.ep_cf_catch.platformHandler

import app.akexorcist.bluetotohspp.library.BluetoothSPP
import io.flutter.plugin.common.EventChannel
import java.util.*

private const val CONNECTION_FAILED = "-1"
private const val DISCONNECTED = "0"
private const val CONNECTED = "1"

class BluetoothStatusHandler(bluetooth: BluetoothSPP)
    : EventChannel.StreamHandler {

    private var statusSink: EventChannel.EventSink? = null

    init {
        bluetooth.setBluetoothConnectionListener(object : BluetoothSPP.BluetoothConnectionListener {
            override fun onDeviceDisconnected() {
                statusSink?.success(HashMap<String, String>().apply {
                    this["status"] = DISCONNECTED
                    this["name"] = ""
                    this["address"] = ""
                })
            }

            override fun onDeviceConnectionFailed() {
                statusSink?.success(HashMap<String, String>().apply {
                    this["status"] = CONNECTION_FAILED
                    this["name"] = ""
                    this["address"] = ""
                })
            }

            override fun onDeviceConnected(name: String, address: String) {
                statusSink?.success(HashMap<String, String>().apply {
                    this["status"] = CONNECTED
                    this["name"] = name
                    this["address"] = address
                })
            }
        })
    }

    override fun onListen(o: Any?, eventSink: EventChannel.EventSink?) {
        statusSink = eventSink
    }

    override fun onCancel(o: Any?) {
        statusSink = null
    }
}