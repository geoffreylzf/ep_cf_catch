import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/module/api_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HousekeepingBloc extends BlocBase{
  final _branchCountSubject = BehaviorSubject<int>();
  final _isLoadingSubject = BehaviorSubject<bool>();

  Stream<int> get branchCountStream => _branchCountSubject.stream;

  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  @override
  void dispose() {
    _branchCountSubject.close();
    _isLoadingSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  HousekeepingBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    _loadCount();
  }

  _loadCount() async {
    _branchCountSubject.add(await BranchDao().getCount());
  }

  retrieveAll() async {
    try {
      _isLoadingSubject.add(true);
      final branchResponse = await ApiModule().getBranch();
      await BranchDao().deleteAll();
      await Future.forEach(branchResponse.result, (ip) async {
        await BranchDao().insert(ip);
      });

      await _loadCount();
      _simpleAlertDialogMixin.onDialogMessage(
          Strings.success, "Housekeeping successfully retrieve.");
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    } finally {
      _isLoadingSubject.add(false);
    }
  }
}
