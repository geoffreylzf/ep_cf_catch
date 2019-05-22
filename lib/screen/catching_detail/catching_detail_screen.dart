import 'package:ep_cf_catch/bloc/bluetooth_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_bloc.dart';
import 'package:ep_cf_catch/screen/catching_detail/widget/catch_summary.dart';
import 'package:ep_cf_catch/screen/catching_detail/widget/detail_entry.dart';
import 'package:ep_cf_catch/screen/catching_detail/widget/temp_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatchingDetailScreen extends StatefulWidget {
  static const String route = '/catchingDetail';
  final CfCatch cfCatch;

  CatchingDetailScreen(this.cfCatch);

  @override
  _CatchingDetailScreenState createState() => _CatchingDetailScreenState();
}

class _CatchingDetailScreenState extends State<CatchingDetailScreen>
    with SimpleAlertDialogMixin, SingleTickerProviderStateMixin {
  BluetoothBloc bluetoothBloc;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    bluetoothBloc = BluetoothBloc(mixin: this, type: BluetoothType.Weighing);
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        //Dismiss keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CatchingDetailBloc>(
          builder: (_) => CatchingDetailBloc(
                mixin: this,
                bluetoothBloc: bluetoothBloc,
                cfCatch: widget.cfCatch,
              ),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<BluetoothBloc>(
          builder: (_) => bluetoothBloc,
          dispose: (_, value) => value.dispose(),
        ),
      ],
      child: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text(Strings.newCatchingDetail),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.view_list)),
                Tab(icon: Icon(Icons.save)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: TempList()),
                  VerticalDivider(width: 0),
                  Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DetailEntry(),
                      )),
                ],
              ),
              CatchSummary(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _onBackPressed(BuildContext context) {
  return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Back to new catch?'),
              content: Text('Unsaved data will be discard...'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(Strings.cancel.toUpperCase()),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(Strings.back.toUpperCase()),
                ),
              ],
            );
          }) ??
      false;
}
