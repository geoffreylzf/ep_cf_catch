package my.com.engpeng.ep_cf_catch

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import app.akexorcist.bluetotohspp.library.BluetoothSPP
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import my.com.engpeng.ep_cf_catch.platformHandler.BarcodeMethodHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothMethodHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothReadHandler
import my.com.engpeng.ep_cf_catch.platformHandler.BluetoothStatusHandler
import io.flutter.plugins.GeneratedPluginRegistrant;

const val BARCODE_METHOD_CHANNEL = "barcode.flutter.io/method"
const val BLUETOOTH_METHOD_CHANNEL = "bluetooth.flutter.io/method"
const val BLUETOOTH_STATUS_CHANNEL = "bluetooth.flutter.io/status"
const val BLUETOOTH_READ_CHANNEL = "bluetooth.flutter.io/read"

class MainActivity : FlutterActivity() {

    private val bluetooth = BluetoothSPP(this)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BARCODE_METHOD_CHANNEL)
                .setMethodCallHandler(BarcodeMethodHandler())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_METHOD_CHANNEL)
                .setMethodCallHandler(BluetoothMethodHandler(bluetooth))

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_STATUS_CHANNEL)
                .setStreamHandler(BluetoothStatusHandler(bluetooth))

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_READ_CHANNEL)
                .setStreamHandler(BluetoothReadHandler(bluetooth))
    }
}
