import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/user.dart';
import 'package:ep_cf_catch/module/api_module.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends BlocBase {
  final _isLogin = BehaviorSubject<bool>.seeded(false);
  final _textGoogleBtn = BehaviorSubject<String>.seeded(Strings.msgSignInWithGoogle);

  Stream<bool> get isLoginStream => _isLogin.stream;

  Stream<String> get textBtnGoogleStream => _textGoogleBtn.stream;

  @override
  void dispose() {
    _isLogin.close();
    _textGoogleBtn.close();
  }

  final _googleSignIn = new GoogleSignIn(scopes: ['email']);
  String _email;
  bool _isGoogleLogin = false;
  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  LoginBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        _textGoogleBtn.add("${account.email} (${Strings.signOut})");
        _isGoogleLogin = true;
        _email = account.email;
      } else {
        _textGoogleBtn.add(Strings.msgSignInWithGoogle);
        _isGoogleLogin = false;
        _email = null;
      }
    });
  }

  Future<bool> login(String username, String password) async {
    if (_email == null || _email.isEmpty) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, "Please login google account");
    } else {
      try {
        await ApiModule().login(username, password, _email);
        await SharedPreferencesModule().saveUser(User(username, password));
        return true;
      } catch (e) {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
      }
    }
    return false;
  }

  onGoogleButtonPressed() {
    if (_isGoogleLogin) {
      _googleSignIn.signOut();
    } else {
      _googleSignIn.signIn();
    }
  }
}
