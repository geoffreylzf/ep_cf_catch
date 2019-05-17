import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/module/bluetooth_module.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

/*const _grossWeight = "G.W.:";
const _tareWeight = "T.W.:";
const _netWeight = "N.W.:";*/
const _kg = "kg";

class BluetoothBloc extends BlocBase {
  final _bluetooth = BluetoothModule();
  var _address = "";
  var _isDispose = false;
  BluetoothType _type;

  final _devicesSubject = BehaviorSubject<List<BluetoothDevice>>.seeded([]);
  final _nameSubject = BehaviorSubject<String>.seeded("");
  final _addressSubject = BehaviorSubject<String>.seeded("");

  final _statusSubject = BehaviorSubject<String>.seeded("Not Connect");
  final _weighingResultSubject = BehaviorSubject<String>.seeded("");

  final _isConnectedSubject = BehaviorSubject<bool>.seeded(false);
  final _isBluetoothEnabledSubject = BehaviorSubject<bool>.seeded(false);

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  BluetoothBloc({@required BluetoothType type, @required SimpleAlertDialogMixin mixin}) {
    _type = type;
    _simpleAlertDialogMixin = mixin;
    initBluetooth();
  }

  initBluetooth() async {
    final isBluetoothAvailable = await _bluetooth.isAvailable;

    if (!isBluetoothAvailable) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Bluetooth not available!");
      return;
    }

    final isBluetoothEnabled = await _bluetooth.isEnabled;

    if (!isBluetoothEnabled) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Bluetooth not enable!");
      return;
    } else {
      _isBluetoothEnabledSubject.add(true);
    }

    await loadDevices();

    _bluetooth.onStatusChanged().listen((btStatus) {
      if (!_isDispose) {
        switch (btStatus.status) {
          case Status.CONNECTED:
            _statusSubject.add("Connected");
            _isConnectedSubject.add(true);
            break;
          case Status.DISCONNECTED:
            _statusSubject.add("Disconnected");
            _isConnectedSubject.add(false);
            break;
          case Status.CONNECTION_FAILED:
            _statusSubject.add("Failed");
            _isConnectedSubject.add(false);
            break;
          default:
            _statusSubject.add("Unknown");
            _isConnectedSubject.add(false);
            break;
        }
      }
    });

    _bluetooth.onRead().listen((data) {
      if (!_isDispose && _type == BluetoothType.Weighing) {
        if (data.contains(_kg)) {
          data = data.replaceAll(_kg, "");
          data = data.trim();
          _weighingResultSubject.add(data);
        }
      }
    });

    var device;
    if (_type == BluetoothType.Printer) {
      device = await SharedPreferencesModule().getBluetoothPrinter();
    } else if (_type == BluetoothType.Weighing) {
      device = await SharedPreferencesModule().getBluetoothWeighing();
    }

    if (device != null) {
      _nameSubject.add(device.name);
      _addressSubject.add(device.address);
      _address = device.address;
      await connectDevice();
    }
  }

  loadDevices() async {
    List<BluetoothDevice> devices = await _bluetooth.getPairedDevices();
    _devicesSubject.sink.add(devices);
  }

  selectDevice(BluetoothDevice device) async {
    _nameSubject.add(device.name);
    _addressSubject.add(device.address);
    _address = device.address;
    await connectDevice();
    if (_type == BluetoothType.Printer) {
      await SharedPreferencesModule().saveBluetoothPrinter(device);
    } else if (_type == BluetoothType.Weighing) {
      await SharedPreferencesModule().saveBluetoothWeighing(device);
    }
  }

  connectDevice() async {
    _statusSubject.add("Connecting");
    await _bluetooth.simpleConnectOther(_address);
  }

  disconnectDevice() async {
    await _bluetooth.stopService();
  }

  print(String qrText, String printText) async {
    if (qrText != null) {
      await _bluetooth.printQr(qrText);
    }
    await _bluetooth.sendText(printText);
  }

  String getWeighingResult() {
    return _weighingResultSubject.value;
  }

  Stream<List<BluetoothDevice>> get devicesStream => _devicesSubject.stream;

  Stream<String> get nameStream => _nameSubject.stream;

  Stream<String> get addressStream => _addressSubject.stream;

  Stream<String> get statusStream => _statusSubject.stream;

  Stream<String> get weighingResultStream => _weighingResultSubject.stream;

  Stream<bool> get isConnectedStream => _isConnectedSubject.stream;

  Stream<bool> get isBluetoothEnabledStream =>
      _isBluetoothEnabledSubject.stream;

  @override
  dispose() {
    _isDispose = true;
    _bluetooth.stopService();

    _devicesSubject.close();
    _nameSubject.close();
    _addressSubject.close();

    _statusSubject.close();
    _weighingResultSubject.close();

    _isConnectedSubject.close();
    _isBluetoothEnabledSubject.close();
  }
}

enum BluetoothType { Weighing, Printer }
