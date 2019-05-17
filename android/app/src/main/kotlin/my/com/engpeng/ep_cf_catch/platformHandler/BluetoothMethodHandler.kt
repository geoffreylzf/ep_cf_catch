package my.com.engpeng.ep_cf_catch.platformHandler

import app.akexorcist.bluetotohspp.library.BluetoothSPP
import app.akexorcist.bluetotohspp.library.BluetoothState
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import my.com.engpeng.ep_cf_catch.module.BarcodeModule
import java.util.*

class BluetoothMethodHandler(
        private val bluetooth: BluetoothSPP)
    : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "isAvailable" -> result.success(bluetooth.isBluetoothAvailable)
            "isEnabled" -> result.success(bluetooth.isBluetoothEnabled)
            "isServiceAvailable" -> result.success(bluetooth.isServiceAvailable)

            "setupService" -> {
                bluetooth.setupService()
                result.success(null)
            }
            "stopService" -> {
                bluetooth.stopService()
                result.success(null)
            }

            "setDeviceTargetAndroid" -> {
                bluetooth.setDeviceTarget(BluetoothState.DEVICE_ANDROID)
                result.success(null)
            }
            "setDeviceTargetOther" -> {
                bluetooth.setDeviceTarget(BluetoothState.DEVICE_OTHER)
                result.success(null)
            }

            "getPairedDevices" -> result.success(getPairedDevices())

            "disconnect" -> {
                bluetooth.disconnect()
                result.success(null)
            }
            "connect" -> {
                if (call.hasArgument("address")) {
                    val address = call.argument<String>("address")
                    bluetooth.connect(address)
                    result.success(null)
                } else {
                    result.error("invalid_argument", "Address not found", null)
                }
            }

            "sendText" -> {
                if (call.hasArgument("text")) {
                    val text = call.argument<String>("text")
                    bluetooth.send(text, true)
                    result.success(null)
                } else {
                    result.error("invalid_argument", "Text not found", null)
                }
            }

            "sendBytes" -> {
                if (call.hasArgument("bytes")) {
                    val bytes = call.argument<ByteArray>("bytes")
                    bluetooth.send(bytes, true)
                    result.success(null)
                } else {
                    result.error("invalid_argument", "Bytes not found", null)
                }
            }

            "printQr" -> {
                if (call.hasArgument("qr")) {
                    val qr = call.argument<String>("qr")!!
                    val bytes = BarcodeModule(qr).convertToQrByteArray()
                    bluetooth.send(bytes, true)
                    result.success(null)
                } else {
                    result.error("invalid_argument", "Qr not found", null)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun getPairedDevices(): ArrayList<Map<String, String>> {
        val nameList = bluetooth.pairedDeviceName.toList()
        val addressList = bluetooth.pairedDeviceAddress.toList()

        val deviceList = ArrayList<Map<String, String>>()

        for (i in nameList.indices) {
            val map = HashMap<String, String>()
            map["name"] = nameList[i]
            map["address"] = addressList[i]
            deviceList.add(map)
        }

        return deviceList
    }
}