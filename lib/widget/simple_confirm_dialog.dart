
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';

class SimpleConfirmDialog extends StatelessWidget {
  final String title, message, btnPositiveText;
  final VoidCallback vcb;
  final String btnNegativeText;

  SimpleConfirmDialog({
    @required this.title,
    @required this.message,
    @required this.btnPositiveText,
    @required this.vcb,
    this.btnNegativeText: Strings.cancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(btnNegativeText.toUpperCase()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(btnPositiveText.toUpperCase()),
          onPressed: () {
            vcb();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
