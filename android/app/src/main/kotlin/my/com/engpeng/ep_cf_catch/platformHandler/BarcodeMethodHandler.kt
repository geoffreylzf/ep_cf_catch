package my.com.engpeng.ep_cf_catch.platformHandler

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import my.com.engpeng.ep_cf_catch.module.BarcodeModule

class BarcodeMethodHandler : MethodChannel.MethodCallHandler {

    companion object {
        private const val method_getQrBytes = "getQrBytes"
        private const val method_getCode128Bytes = "getCode128Bytes"
        private const val param_text = "text"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            method_getQrBytes -> {

                val text: String = call.argument(param_text)!!
                val qrCode = BarcodeModule(text).convertToQrByteArray()

                result.success(qrCode)
            }
            method_getCode128Bytes -> {

                val text: String = call.argument(param_text)!!
                val qrCode = BarcodeModule(text).convertToCode128ByteArray()

                result.success(qrCode)
            }
            else -> result.notImplemented()
        }
    }

}