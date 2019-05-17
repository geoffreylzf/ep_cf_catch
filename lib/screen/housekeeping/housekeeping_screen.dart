import 'package:ep_cf_catch/bloc/local_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/housekeeping/housekeeping_bloc.dart';
import 'package:ep_cf_catch/widget/local_check_box.dart';
import 'package:ep_cf_catch/widget/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HousekeepingScreen extends StatefulWidget {
  static const String route = '/housekeeping';

  @override
  _HousekeepingScreenState createState() => _HousekeepingScreenState();
}

class _HousekeepingScreenState extends State<HousekeepingScreen>
    with SimpleAlertDialogMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HousekeepingBloc>(
          builder: (_) => HousekeepingBloc(mixin: this),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<LocalBloc>(
          builder: (_) => LocalBloc(),
          dispose: (_, value) => value.dispose(),
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("Housekeeping"),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HkList(),
                ActionPanel(),
              ],
            ),
            Consumer<HousekeepingBloc>(builder: (ctx, value, child) {
              return SimpleLoadingDialog(value.isLoadingStream);
            })
          ],
        ),
      ),
    );
  }
}

class HkList extends StatefulWidget {
  @override
  _HkListState createState() => _HkListState();
}

class _HkListState extends State<HkList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<HousekeepingBloc>(context);

    return Column(
      children: [
        HkRow("Branch", bloc.branchCountStream),
      ],
    );
  }
}

class HkRow extends StatefulWidget {
  final String desc;
  final Stream<int> stream;

  HkRow(this.desc, this.stream);

  @override
  _HkRowState createState() => _HkRowState();
}

class _HkRowState extends State<HkRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36),
      child: Container(
        padding: EdgeInsets.all(16),
        color: Theme.of(context).primaryColorLight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.desc),
            StreamBuilder<int>(
                initialData: 0,
                stream: widget.stream,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class ActionPanel extends StatefulWidget {
  @override
  _ActionPanelState createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  @override
  Widget build(BuildContext context) {
    final hkBloc = Provider.of<HousekeepingBloc>(context);
    final localBloc = Provider.of<LocalBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LocalCheckBox(
          localBloc: localBloc,
        ),
        RaisedButton.icon(
          onPressed: () {
            hkBloc.retrieveAll();
          },
          icon: Icon(Icons.cloud_download),
          label: Text(Strings.retrieveHousekeeping.toUpperCase()),
        ),
      ],
    );
  }
}
