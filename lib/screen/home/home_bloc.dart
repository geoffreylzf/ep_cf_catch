import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BlocBase{
  final _companySubject = BehaviorSubject<Branch>();

  Stream<Branch> get companyStream => _companySubject.stream;

  @override
  void dispose() {
    _companySubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  HomeBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    loadCompany();
  }

  loadCompany() async {
    var companyId = await SharedPreferencesModule().getCompanyId();
    if(companyId != null){
      _companySubject.add(await BranchDao().getCompanyById(companyId));
    }
  }

  showNoCompanyDialog() {
    _simpleAlertDialogMixin.onDialogMessage(
        Strings.error, "Please select company");
  }
}
