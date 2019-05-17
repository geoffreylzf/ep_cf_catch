package my.com.engpeng.ep_cf_catch.platformHandler

import app.akexorcist.bluetotohspp.library.BluetoothSPP
import io.flutter.plugin.common.EventChannel

class BluetoothReadHandler(bluetooth: BluetoothSPP)
    : EventChannel.StreamHandler {

    init {
        bluetooth.setOnDataReceivedListener { _, message ->
            readSink?.success(message)
        }
    }

    private var readSink: EventChannel.EventSink? = null

    override fun onListen(o: Any?, eventSink: EventChannel.EventSink?) {
        readSink = eventSink
    }

    override fun onCancel(o: Any?) {
        readSink = null
    }
}