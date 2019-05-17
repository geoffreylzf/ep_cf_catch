import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching/widget/head_entry.dart';
import 'package:ep_cf_catch/screen/catching/widget/location_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'catching_bloc.dart';

class CatchingScreen extends StatefulWidget {
  static const String route = '/catching';
  final int companyId;

  CatchingScreen(this.companyId);

  @override
  _CatchingScreenState createState() => _CatchingScreenState();
}

class _CatchingScreenState extends State<CatchingScreen>
    with SimpleAlertDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Provider<CatchingBloc>(
      builder: (_) => CatchingBloc(mixin: this, companyId: widget.companyId),
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.newCatching),
        ),
        body: Row(
          children: [
            Expanded(child: LocationSelection()),
            VerticalDivider(width: 0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: HeadEntry(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
