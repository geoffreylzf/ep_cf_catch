import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/user.dart';
import 'package:ep_cf_catch/module/api_module.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final _isLogin = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get isLoginStream => _isLogin.stream;


  @override
  void dispose() {
    _isLogin.close();
  }
  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  LoginBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;

  }

  Future<bool> login(String username, String password) async {
    try {
      await ApiModule().login(username, password);
      await SharedPreferencesModule().saveUser(User(username, password));
      return true;
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    }
    return false;
  }
}
