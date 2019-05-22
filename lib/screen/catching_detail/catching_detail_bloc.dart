import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/bloc/bluetooth_bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_detail_dao.dart';
import 'package:ep_cf_catch/db/dao/temp_cf_catch_detail_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/table/cf_catch_detail.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_detail.dart';
import 'package:ep_cf_catch/model/temp_total.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibrate/vibrate.dart';
import 'package:uuid/uuid.dart';

class CatchingDetailBloc extends BlocBase {
  final _cfCatchSubject = BehaviorSubject<CfCatch>();
  final _tempListSubject = BehaviorSubject<List<TempCfCatchDetail>>();
  final _tempTotalSubject = BehaviorSubject<TempTotal>();
  final _cageQtySubject = BehaviorSubject<int>();
  final _coverQtySubject = BehaviorSubject<int>();
  final _weightSubject = BehaviorSubject<double>();
  final _isWeighingByBtSubject = BehaviorSubject<bool>.seeded(false);

  Stream<CfCatch> get cfCatchStream => _cfCatchSubject.stream;

  Stream<List<TempCfCatchDetail>> get tempListStream => _tempListSubject.stream;

  Stream<TempTotal> get tempTotalStream => _tempTotalSubject.stream;

  Stream<int> get cageQtyStream => _cageQtySubject.stream;

  Stream<int> get coverQtyStream => _coverQtySubject.stream;

  Stream<double> get weightStream => _weightSubject.stream;

  Stream<bool> get isWeighingByBtStream => _isWeighingByBtSubject.stream;

  @override
  void dispose() {
    _cfCatchSubject.close();
    _tempListSubject.close();
    _tempTotalSubject.close();
    _cageQtySubject.close();
    _coverQtySubject.close();
    _weightSubject.close();
    _isWeighingByBtSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;
  BluetoothBloc _bluetoothBloc;
  CfCatch _cfCatch;

  CatchingDetailBloc({
    @required SimpleAlertDialogMixin mixin,
    @required BluetoothBloc bluetoothBloc,
    @required CfCatch cfCatch,
  }) {
    _simpleAlertDialogMixin = mixin;
    _bluetoothBloc = bluetoothBloc;
    _cfCatch = cfCatch;

    _cfCatchSubject.add(_cfCatch);

    _bluetoothBloc.weighingResultStream.listen((data) {
      final weight = double.tryParse(data);
      _weightSubject.add(weight);
    });

    _loadTempList();
  }

  _loadTempList() async {
    _tempListSubject.add(await TempCfCatchDetailDao().getList());
    _tempTotalSubject.add(await TempCfCatchDetailDao().getTotal());
  }

  setCateQty(int cage) {
    _cageQtySubject.add(cage);
    _coverQtySubject.add(cage);
  }

  setCoverQty(int cover) {
    _coverQtySubject.add(cover);
  }

  setIsWeighingByBt(bool b) {
    _isWeighingByBtSubject.add(b);
  }

  bool getIsWeighingByBt() {
    return _isWeighingByBtSubject.value;
  }

  double getWeight() {
    return _weightSubject.value;
  }

  Future<String> getLocationCodeName() async {
    final location = await BranchDao().getLocationById(_cfCatch.locationId);
    return location.branchCode + " - " + location.branchName;
  }

  Future<bool> insertDetail(int house, int age, double weight, int qty) async {
    final cageQty = _cageQtySubject.value;
    final coverQty = _coverQtySubject.value;
    if (house == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please enter house");
      return false;
    }
    if (age == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please enter age");
      return false;
    }
    if (weight == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please enter weight");
      return false;
    }
    if (qty == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please enter quantity");
      return false;
    }
    if (cageQty == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please select cage quantity");
      return false;
    }
    if (coverQty == null) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please select cover quantity");
      return false;
    }
    final isBt = _isWeighingByBtSubject.value ? 1 : 0;
    final temp = TempCfCatchDetail(
      houseNo: house,
      age: age,
      weight: weight,
      qty: qty,
      cageQty: cageQty,
      coverQty: coverQty,
      isBt: isBt,
    );

    await TempCfCatchDetailDao().insert(temp);
    await _loadTempList();
    Vibrate.vibrate();
    return true;
  }

  deleteDetail(int id) async {
    await TempCfCatchDetailDao().deleteById(id);
    await _loadTempList();
  }

  Future<bool> validate() async {
    final temp = await TempCfCatchDetailDao().getList();
    if (temp.length == 0) {
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.error, "Please enter at least 1 data to save.");
      return false;
    }
    return true;
  }

  Future<int> saveCatch() async {
    final cfCatch = CfCatch.db(
      companyId: _cfCatch.companyId,
      locationId: _cfCatch.locationId,
      recordDate: _cfCatch.recordDate,
      docNo: _cfCatch.docNo,
      truckNo: _cfCatch.truckNo,
      refNo: _cfCatch.refNo,
      uuid: Uuid().v1(),
    );

    final cfCatchId = await CfCatchDao().insert(cfCatch);
    final tempList = await TempCfCatchDetailDao().getList();
    final detailList = CfCatchDetail.fromTempWithCfCatchId(cfCatchId, tempList);

    await Future.forEach(detailList, (detail) async {
      await CfCatchDetailDao().insert(detail);
    });

    await TempCfCatchDetailDao().deleteAll();

    return cfCatchId;
  }
}
