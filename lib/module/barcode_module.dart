import 'dart:typed_data';

import 'package:flutter/services.dart';

class BarcodeModule {
  static final _instance = BarcodeModule._internal();

  factory BarcodeModule() => _instance;

  BarcodeModule._internal();

  static const MethodChannel _channel =
  const MethodChannel("barcode.epfeedmill.flutter.io/method");

  Future<Uint8List> generateQrCode(String text) async =>
      await _channel.invokeMethod('getQrBytes', {'text': text});

  Future<Uint8List> generateCode128Code(String text) async =>
      await _channel.invokeMethod('getCode128Bytes', {'text': text});
}
