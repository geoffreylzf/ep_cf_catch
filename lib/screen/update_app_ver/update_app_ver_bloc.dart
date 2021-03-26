import 'dart:convert';

import 'package:ep_cf_catch/bloc/bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const BASE_LOCAL_URL = "http://192.168.8.6";
const BASE_GLOBAL_URL = "http://epgroup.dyndns.org:5031";

class UpdateAppVerBloc extends BlocBase {
  final _verCodeSubject = BehaviorSubject<int>();
  final _verNameSubject = BehaviorSubject<String>();
  final _appCodeSubject = BehaviorSubject<String>();

  Stream<int> get verCodeStream => _verCodeSubject.stream;

  Stream<String> get verNameStream => _verNameSubject.stream;

  Stream<String> get appCodeStream => _appCodeSubject.stream;

  @override
  void dispose() {
    _verCodeSubject.close();
    _verNameSubject.close();
    _appCodeSubject.close();
  }

  SimpleAlertDialogMixin _simpleAlertDialogMixin;

  UpdateAppVerBloc({@required SimpleAlertDialogMixin mixin}) {
    _simpleAlertDialogMixin = mixin;
    _init();
  }

  _init() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    _verCodeSubject.add(int.tryParse(info.buildNumber));
    _verNameSubject.add(info.version);
    _appCodeSubject.add(info.packageName);
  }

  void updateApp() async {
    String url = "/api/info/mobile/apps/${_appCodeSubject.value}/latest";

    try {
      final isLocal = await SharedPreferencesModule().getLocalCheck() ?? false;
      if (isLocal) {
        url = BASE_LOCAL_URL + url;
      } else {
        url = BASE_GLOBAL_URL + url;
      }

      final response = await http.get(url);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final res = jsonDecode(response.body);
        final latestVerCode = int.tryParse(res['version_code'].toString());
        final latestVerDownloadLink = res['download_link'].toString();

        if (latestVerCode > _verCodeSubject.value) {
          if (await canLaunch(latestVerDownloadLink)) {
            await launch(latestVerDownloadLink);
          } else {
            _simpleAlertDialogMixin.onDialogMessage(
                Strings.error, "Cannot launch download apk url");
          }
        } else if (latestVerCode == _verCodeSubject.value) {
          _simpleAlertDialogMixin.onDialogMessage(
              Strings.error, "Current app is the latest version");
        } else {
          _simpleAlertDialogMixin.onDialogMessage(Strings.error,
              "Current Ver : ${_verCodeSubject.value} \nLatest Ver : $latestVerCode");
        }
      } else {
        _simpleAlertDialogMixin.onDialogMessage(Strings.error, response.body);
      }
    } catch (e) {
      _simpleAlertDialogMixin.onDialogMessage(Strings.error, e.toString());
    }
  }
}
