package my.com.engpeng.ep_cf_catch

import android.os.Bundle
import app.akexorcist.bluetotohspp.library.BluetoothSPP

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import my.com.engpeng.ep_cf_catch.platformHandler.BarcodeMethodHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothMethodHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothReadHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothStatusHandler

const val BARCODE_METHOD_CHANNEL = "barcode.flutter.io/method"
const val BLUETOOTH_METHOD_CHANNEL = "bluetooth.flutter.io/method"
const val BLUETOOTH_STATUS_CHANNEL = "bluetooth.flutter.io/status"
const val BLUETOOTH_READ_CHANNEL = "bluetooth.flutter.io/read"

class MainActivity : FlutterActivity() {

    private val bluetooth = BluetoothSPP(this)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, BARCODE_METHOD_CHANNEL).setMethodCallHandler(BarcodeMethodHandler())

        MethodChannel(flutterView, BLUETOOTH_METHOD_CHANNEL)
                .setMethodCallHandler(BluetoothMethodHandler(bluetooth))

        EventChannel(flutterView, BLUETOOTH_STATUS_CHANNEL)
                .setStreamHandler(BluetoothStatusHandler(bluetooth))

        EventChannel(flutterView, BLUETOOTH_READ_CHANNEL)
                .setStreamHandler(BluetoothReadHandler(bluetooth))

    }
}
