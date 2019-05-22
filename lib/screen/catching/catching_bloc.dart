import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class CatchingBloc extends BlocBase {
  final _locListSubject = BehaviorSubject<List<Branch>>();
  final _selectedLocationIdSubject = BehaviorSubject<int>();

  Stream<List<Branch>> get locListStream => _locListSubject.stream;

  Stream<int> get selectedLocationIdStream => _selectedLocationIdSubject.stream;

  @override
  void dispose() {
    _locListSubject.close();
    _selectedLocationIdSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;
  int _companyId;

  CatchingBloc({
    @required SimpleAlertDialogMixin mixin,
    @required int companyId,
  }) {
    _simpleAlertDialogMixin = mixin;
    _companyId = companyId;
    _loadLocList("");
  }

  _loadLocList(String filter) async {
    _locListSubject.add(await BranchDao().getLocationListByCompanyIdFilter(_companyId, filter));
  }

  setLocationId(int locationId) {
    _selectedLocationIdSubject.add(locationId);
  }

  CfCatch validateEntry(String recordDate, String docNo, String truckNo, String refNo) {
    if (_selectedLocationIdSubject.value == null) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please select location");
      return null;
    }
    if (recordDate == null || recordDate == "") {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please select date");
      return null;
    }
    if (docNo == null || docNo == "") {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please enter document number");
      return null;
    }
    if (truckNo == null || truckNo == "") {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please enter truck code");
      return null;
    }

    return CfCatch(
        companyId: _companyId,
        locationId: _selectedLocationIdSubject.value,
        recordDate: recordDate,
        docNo: docNo,
        truckNo: truckNo,
        refNo: refNo);
  }

  searchLocation(String filter) async {
    await _loadLocList(filter);
    var locList = _locListSubject.value;
    var locationId = _selectedLocationIdSubject.value;
    if (locationId != null) {
      var isContained = locList.map((b) => b.id).contains(locationId);
      if (!isContained) {
        setLocationId(null);
      }
    }
  }

  Future<ScanResult> scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      var strList = barcode.split("|");
      if (strList.length < 7) {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Invalid barcode");
        return ScanResult(isSuccess: false);
      }

      //int companyId = int.tryParse(strList[0]);
      int locationId = int.tryParse(strList[1]);
      String date = strList[2];
      int docNo = int.tryParse(strList[3]);
      //String docType = strList[4];
      //String type = strList[5];
      String truckNo = strList[6];

      return ScanResult(
        isSuccess: true,
        date: date,
        docNo: docNo,
        truckNo: truckNo,
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please grant camera permission");
      } else {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Unknown error: $e");
      }
    } on FormatException {
      //User return using back button
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Unknown error: $e");
    }
    return ScanResult(isSuccess: false);
  }
}

class ScanResult {
  final bool isSuccess;
  int docNo;
  String date, truckNo;

  ScanResult({this.isSuccess, this.date, this.docNo, this.truckNo});
}
