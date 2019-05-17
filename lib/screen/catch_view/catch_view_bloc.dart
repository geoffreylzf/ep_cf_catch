import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_detail_dao.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/table/cf_catch_detail.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CatchViewBloc extends BlocBase {
  final _cfCatchSubject = BehaviorSubject<CfCatch>();
  final _cfCatchDetailListSubject = BehaviorSubject<List<CfCatchDetail>>();

  Stream<CfCatch> get cfCatchStream => _cfCatchSubject.stream;

  Stream<List<CfCatchDetail>> get cfCatchDetailListStream =>
      _cfCatchDetailListSubject.stream;

  @override
  void dispose() {
    _cfCatchSubject.close();
    _cfCatchDetailListSubject.close();
  }

  int _cfCatchId;

  CatchViewBloc({@required int cfCatchId}) {
    _cfCatchId = cfCatchId;
    _init();
  }

  _init() async {
    _loadCfCatch();
    _cfCatchDetailListSubject
        .add(await CfCatchDetailDao().getListByCfCatchId(_cfCatchId));
  }

  _loadCfCatch() async {
    _cfCatchSubject.add(await CfCatchDao().getById(_cfCatchId));
  }

  deleteCfCatch() async {
    final premix = await CfCatchDao().getById(_cfCatchId);
    premix.isDelete = 1;
    await CfCatchDao().update(premix);
    await _loadCfCatch();
  }

  CfCatch getCfCatch() {
    return _cfCatchSubject.value;
  }

  Future<String> getLocationCodeName() async {
    if (_cfCatchSubject.hasValue) {
      final location =
          await BranchDao().getLocationById(_cfCatchSubject.value.locationId);
      if (location != null) {
        return location.branchCode + " - " + location.branchName;
      }
      return "";
    } else {
      return "";
    }
  }
}
