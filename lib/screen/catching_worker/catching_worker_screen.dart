import 'dart:async';

import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/person_staff.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_worker.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching_worker/catching_worker_bloc.dart';
import 'package:ep_cf_catch/widget/simple_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatchingWorkerScreen extends StatefulWidget {
  static const String route = '/catchingWorker';

  @override
  _CatchingWorkerScreenState createState() => _CatchingWorkerScreenState();
}

class _CatchingWorkerScreenState extends State<CatchingWorkerScreen> with SimpleAlertDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Provider<CatchingWorkerBloc>(
      builder: (_) => CatchingWorkerBloc(mixin: this),
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.newCatchingWorker),
        ),
        body: Stack(
          children: [
            Row(
              children: [
                Expanded(child: PersonStaffSelection()),
                VerticalDivider(width: 0),
                Expanded(
                  child: Column(
                    children: [
                      ManualEnterWorkerPanel(),
                      Divider(height: 0),
                      Expanded(child: WorkerList()),
                    ],
                  ),
                ),
              ],
            ),
            Consumer<CatchingWorkerBloc>(builder: (ctx, value, child) {
              return SimpleLoadingDialog(value.isFetchingStream);
            })
          ],
        ),
      ),
    );
  }
}

class PersonStaffSelection extends StatefulWidget {
  @override
  _PersonStaffSelectionState createState() => _PersonStaffSelectionState();
}

class _PersonStaffSelectionState extends State<PersonStaffSelection> {
  final searchTec = TextEditingController();
  Timer _debounce;

  @override
  void dispose() {
    searchTec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingWorkerBloc>(context);

    searchTec.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        String filter = searchTec.text;
        bloc.searchPersonStaff(filter);
      });
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchTec,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.search,
              contentPadding: const EdgeInsets.all(8.0),
            ),
          ),
        ),
        Expanded(
            child: StreamBuilder<List<PersonStaff>>(
                stream: bloc.personStaffListStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data;
                  return ListView.separated(
                      separatorBuilder: (ctx, index) => Divider(height: 0),
                      itemCount: list.length,
                      itemBuilder: (ctx, position) {
                        final ps = list[position];

                        return StreamBuilder<List<TempCfCatchWorker>>(
                            stream: bloc.tempListStream,
                            initialData: [],
                            builder: (context, snapshot) {
                              final cwList = snapshot.data;

                              var bgColor = Theme.of(ctx).scaffoldBackgroundColor;
                              var isSelected = false;

                              final cw = cwList.firstWhere((x) => x.personStaffId == ps.id,
                                  orElse: () => null);
                              if (cw != null) {
                                bgColor = Theme.of(ctx).primaryColorLight;
                                isSelected = true;
                              }

                              return Container(
                                color: bgColor,
                                child: ListTile(
                                  leading: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.person_outline),
                                  ),
                                  title: Text(ps.personName),
                                  subtitle: Text(ps.personCode),
                                  onTap: () {
                                    if (isSelected) {
                                      bloc.deleteWorker(cw.id);
                                    } else {
                                      bloc.insertWorker(personStaffId: ps.id);
                                    }
                                  },
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (b) {
                                      if (isSelected) {
                                        bloc.deleteWorker(cw.id);
                                      } else {
                                        bloc.insertWorker(personStaffId: ps.id);
                                      }
                                    },
                                  ),
                                ),
                              );
                            });
                      });
                })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              onPressed: () {
                bloc.fetchPersonStaff();
              },
              icon: Icon(Icons.cloud_download),
              label: Text(Strings.retrieveLatestStaff.toUpperCase()),
            ),
          ),
        ),
      ],
    );
  }
}

class ManualEnterWorkerPanel extends StatefulWidget {
  @override
  _ManualEnterWorkerPanelState createState() => _ManualEnterWorkerPanelState();
}

class _ManualEnterWorkerPanelState extends State<ManualEnterWorkerPanel> {
  final tecWorkerName = TextEditingController();

  @override
  void dispose() {
    tecWorkerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingWorkerBloc>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("Manual Enter Worker", style: TextStyle(color: Colors.grey)),
          ),
          TextField(
            controller: tecWorkerName,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.workerName,
              contentPadding: const EdgeInsets.all(8.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: bloc.isFarmWorkerStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return Checkbox(
                        value: snapshot.data,
                        onChanged: (bool _) {
                          bloc.toggleIsFarmWorker();
                        },
                      );
                    }),
                Flexible(
                  fit: FlexFit.loose,
                  child: InkWell(
                    onTap: () => bloc.toggleIsFarmWorker(),
                    child: Text(
                      "Farm Worker (Not Catching Team)",
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              onPressed: () async {
                if (await bloc.insertWorker(workerName: tecWorkerName.text)) {
                  tecWorkerName.text = "";
                }
              },
              icon: Icon(Icons.add),
              label: Text(Strings.addWorker.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerList extends StatefulWidget {
  @override
  _WorkerListState createState() => _WorkerListState();
}

class _WorkerListState extends State<WorkerList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingWorkerBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text("Worker List", style: TextStyle(color: Colors.grey)),
        ),
        Divider(height: 0),
        Expanded(
          child: StreamBuilder<List<TempCfCatchWorker>>(
              stream: bloc.tempListStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                var list = snapshot.data;
                return ListView.separated(
                  separatorBuilder: (ctx, index) => Divider(height: 0),
                  itemCount: list.length,
                  itemBuilder: (ctx, position) {
                    final temp = list[position];

                    var hint = "";
                    if (temp.personStaffId == null) {
                      hint = "* ";
                    }

                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: PageStorageKey(list[position].id.toString()),
                      onDismissed: (direction) {
                        bloc.deleteWorker(list[position].id);
                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete this worker?"),
                                content: Text("Worker Name : ${temp.workerName}"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(Strings.cancel.toUpperCase()),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(Strings.delete.toUpperCase()),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: ListTile(
                        title: Text(hint + temp.workerName),
                        subtitle: temp.isFarmWorker == 1
                            ? Text("Farm Worker", style: TextStyle(color: Colors.red))
                            : null,
                      ),
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}
