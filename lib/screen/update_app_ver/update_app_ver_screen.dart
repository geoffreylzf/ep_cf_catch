import 'package:ep_cf_catch/bloc/local_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/screen/update_app_ver/update_app_ver_bloc.dart';
import 'package:ep_cf_catch/widget/local_check_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateAppVerScreen extends StatefulWidget {
  static const String route = '/updateAppVer';

  @override
  _UpdateAppVerScreenState createState() => _UpdateAppVerScreenState();
}

class _UpdateAppVerScreenState extends State<UpdateAppVerScreen> with SimpleAlertDialogMixin {
  UpdateAppVerBloc updateAppVerBloc;
  LocalBloc localBloc;

  @override
  void initState() {
    super.initState();
    updateAppVerBloc = UpdateAppVerBloc(mixin: this);
    localBloc = LocalBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<UpdateAppVerBloc>(
            builder: (_) => updateAppVerBloc,
            dispose: (_, value) => value.dispose(),
          ),
          Provider<LocalBloc>(
            builder: (_) => localBloc,
            dispose: (_, value) => value.dispose(),
          )
        ],
        child: Scaffold(
          appBar: AppBar(title: Text('Update App Version')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<int>(
                    stream: updateAppVerBloc.verCodeStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      return Text("Version Code : ${snapshot.data}");
                    }),
                StreamBuilder<String>(
                    stream: updateAppVerBloc.verNameStream,
                    initialData: "",
                    builder: (context, snapshot) {
                      return Text("Version Name : ${snapshot.data}");
                    }),
                RaisedButton.icon(
                  onPressed: () => updateAppVerBloc.updateApp(),
                  icon: Icon(Icons.update),
                  label: Text("UPDATE APP VERSION"),
                ),
                LocalCheckBox(
                  localBloc: localBloc,
                )
              ],
            ),
          ),
        ));
  }
}
