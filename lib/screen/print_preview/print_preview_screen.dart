import 'package:ep_cf_catch/bloc/bluetooth_bloc.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/print_data.dart';
import 'package:ep_cf_catch/module/bluetooth_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrintPreviewScreen extends StatefulWidget {
  static const String route = '/printPreview';

  final PrintData printData;

  PrintPreviewScreen(this.printData);

  @override
  _PrintPreviewScreenState createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen>
    with SimpleAlertDialogMixin {
  BluetoothBloc bluetoothBloc;

  @override
  void initState() {
    super.initState();
    bluetoothBloc = BluetoothBloc(mixin: this, type: BluetoothType.Printer);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BluetoothBloc>(
          builder: (_) => bluetoothBloc,
          dispose: (_, value) => value.dispose(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.printPreview),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: BluetoothPanel(widget.printData),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          widget.printData.text,
                          style: TextStyle(fontFamily: 'MonoSpace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothPanel extends StatefulWidget {
  final PrintData printData;

  BluetoothPanel(this.printData);

  @override
  _BluetoothPanelState createState() => _BluetoothPanelState();
}

class _BluetoothPanelState extends State<BluetoothPanel> {
  @override
  Widget build(BuildContext context) {
    final bluetoothBloc = Provider.of<BluetoothBloc>(context);
    return Row(
      children: <Widget>[
        StreamBuilder<bool>(
            stream: bluetoothBloc.isBluetoothEnabledStream,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.bluetooth),
                iconSize: 60,
                onPressed: snapshot.data
                    ? () => showBluetoothDevices(context, bluetoothBloc)
                    : null,
                color: Theme.of(context).primaryColor,
                splashColor: Theme.of(context).accentColor,
              );
            }),
        StreamBuilder<bool>(
            stream: bluetoothBloc.isBluetoothEnabledStream,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 60,
                onPressed:
                    snapshot.data ? () => bluetoothBloc.connectDevice() : null,
                color: Theme.of(context).primaryColor,
                splashColor: Theme.of(context).accentColor,
              );
            }),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<String>(
                  stream: bluetoothBloc.statusStream,
                  builder: (context, snapshot) {
                    return Text(
                      "${Strings.status} : ${snapshot.data.toString()}",
                      style: TextStyle(fontSize: 12),
                    );
                  }),
              StreamBuilder<String>(
                  stream: bluetoothBloc.nameStream,
                  builder: (context, snapshot) {
                    return Text("${Strings.name} : ${(snapshot.data ?? "")}",
                        style: TextStyle(fontSize: 12));
                  }),
              StreamBuilder<String>(
                  stream: bluetoothBloc.addressStream,
                  builder: (context, snapshot) {
                    return Text("${Strings.address} : ${(snapshot.data ?? "")}",
                        style: TextStyle(fontSize: 12));
                  }),
            ],
          ),
        ),
        StreamBuilder<bool>(
            stream: bluetoothBloc.isConnectedStream,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.print),
                iconSize: 60,
                onPressed: snapshot.data
                    ? () => bluetoothBloc.print(
                        widget.printData.barcode, widget.printData.text)
                    : null,
                color: Theme.of(context).primaryColor,
                splashColor: Theme.of(context).accentColor,
              );
            }),
      ],
    );
  }

  void showBluetoothDevices(BuildContext context, BluetoothBloc bluetoothBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          bluetoothBloc.loadDevices();
          return AlertDialog(
            title: const Text(Strings.bluetoothDevices),
            content: Container(
              height: 300.0,
              width: 300.0,
              child: StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothBloc.devicesStream,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data.isEmpty) {
                      return Center(
                          child: Text('Empty',
                              style: Theme.of(context).textTheme.display1));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final devices = snapshot.data;
                        return Container(
                          color: (index % 2 == 0)
                              ? Theme.of(context).primaryColorLight
                              : Theme.of(context).scaffoldBackgroundColor,
                          child: ListTile(
                            onTap: () {
                              bluetoothBloc.selectDevice(devices[index]);
                              Navigator.pop(context);
                            },
                            title: Row(
                              children: <Widget>[
                                Expanded(child: Text(devices[index].name)),
                                Expanded(child: Text(devices[index].address)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          );
        });
  }
}
