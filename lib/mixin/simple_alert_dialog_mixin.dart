import 'package:ep_cf_catch/widget/simple_alert_dialog.dart';
import 'package:flutter/material.dart';

mixin SimpleAlertDialogMixin<T extends StatefulWidget> on State<T> {
  void onDialogMessage(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleAlertDialog(
            title: title,
            message: message,
          );
        });
  }
}
