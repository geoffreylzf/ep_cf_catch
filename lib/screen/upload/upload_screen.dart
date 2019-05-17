import 'package:ep_cf_catch/bloc/local_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/log.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/upload/upload_bloc.dart';
import 'package:ep_cf_catch/widget/local_check_box.dart';
import 'package:ep_cf_catch/widget/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadScreen extends StatefulWidget {
  static const String route = '/upload';

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SimpleAlertDialogMixin {

  UploadBloc uploadBloc;

  @override
  void initState() {
    super.initState();
    uploadBloc = UploadBloc(mixin: this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<UploadBloc>(
            builder: (_) => uploadBloc,
            dispose: (_, value) => value.dispose(),
          ),
          Provider<LocalBloc>(
            builder: (_) => LocalBloc(),
            dispose: (_, value) => value.dispose(),
          )
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(Strings.upload),
          ),
          body: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: UploadLog()),
                  VerticalDivider(width: 0),
                  Expanded(child: UploadStatus()),
                ],
              ),
              SimpleLoadingDialog(uploadBloc.isLoadingStream),
            ],
          ),
        ));
  }
}

class UploadLog extends StatefulWidget {
  @override
  _UploadLogState createState() => _UploadLogState();
}

class _UploadLogState extends State<UploadLog> {
  @override
  Widget build(BuildContext context) {
    final uploadBloc = Provider.of<UploadBloc>(context);
    return StreamBuilder<List<Log>>(
        stream: uploadBloc.uploadLogListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data;
          return ListView.separated(
            separatorBuilder: (ctx, index) => Divider(height: 0),
            itemCount: list.length,
            itemBuilder: (ctx, position) {
              final log = list[position];
              return ListTile(
                title: Text(log.remark),
                subtitle: Text(log.timestamp),
              );
            },
          );
        });
  }
}

class UploadStatus extends StatefulWidget {
  @override
  _UploadStatusState createState() => _UploadStatusState();
}

class _UploadStatusState extends State<UploadStatus> {
  @override
  Widget build(BuildContext context) {
    final uploadBloc = Provider.of<UploadBloc>(context);
    final localBloc = Provider.of<LocalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Text(Strings.msgPendingNotYetUploadData),
        StreamBuilder<int>(
            stream: uploadBloc.noUploadCountStream,
            initialData: 0,
            builder: (context, snapshot) {
              return Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 200),
              );
            }),
        RaisedButton.icon(
            onPressed: () {
              uploadBloc.upload();
            },
            icon: Icon(Icons.cloud_upload),
            label: Text(Strings.upload.toUpperCase())),
        Expanded(
          flex: 3,
          child: LocalCheckBox(
            localBloc: localBloc,
          ),
        ),
      ],
    );
  }
}