import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/db/dao/util_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:package_info/package_info.dart';

class HomeBloc extends BlocBase{
  final _companySubject = BehaviorSubject<Branch>();
  final _packageInfoSubject = BehaviorSubject<PackageInfo>();
  final _noUploadCountSubject = BehaviorSubject<int>();

  Stream<Branch> get companyStream => _companySubject.stream;
  Stream<PackageInfo> get packageInfoStream => _packageInfoSubject.stream;
  Stream<int> get noUploadCountStream => _noUploadCountSubject.stream;

  @override
  void dispose() {
    _companySubject.close();
    _packageInfoSubject.close();
    _noUploadCountSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  HomeBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    loadCompany();
    loadNoUploadCount();
    _loadPackageInfo();
  }

  loadCompany() async {
    var companyId = await SharedPreferencesModule().getCompanyId();
    if(companyId != null){
      _companySubject.add(await BranchDao().getCompanyById(companyId));
    }
  }

  loadNoUploadCount() async {
    _noUploadCountSubject.add(await UtilDao().getNoUploadCount());
  }

  _loadPackageInfo() async {
    _packageInfoSubject.add(await PackageInfo.fromPlatform());
  }

  showNoCompanyDialog() {
    _simpleAlertDialogMixin.onDialogMessage(
        Strings.error, "Please select company");
  }
}
