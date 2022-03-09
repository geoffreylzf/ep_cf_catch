import 'package:ep_cf_catch/model/table/temp_cf_catch_worker.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching/catching_bloc.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_screen.dart';
import 'package:ep_cf_catch/screen/catching_worker/catching_worker_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HeadEntry extends StatefulWidget {
  @override
  _HeadEntryState createState() => _HeadEntryState();
}

class _HeadEntryState extends State<HeadEntry> {
  var recordDate = DateTime.now();
  var dateFormat = DateFormat('yyyy-MM-dd');
  var dateTec = TextEditingController();
  var docNoTec = TextEditingController();
  var truckNoTec = TextEditingController();
  var refNoTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateTec.text = dateFormat.format(recordDate);
  }

  @override
  void dispose() {
    dateTec.dispose();
    docNoTec.dispose();
    truckNoTec.dispose();
    refNoTec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingBloc>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<bool>(
                  stream: bloc.isScanStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return Column(
                      children: <Widget>[
                        TextField(
                          enabled: !snapshot.data,
                          controller: dateTec,
                          enableInteractiveSelection: false,
                          focusNode: AlwaysDisabledFocusNode(),
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: recordDate,
                              firstDate: DateTime(2010),
                              lastDate: DateTime(2050),
                            );

                            if (selectedDate != null) {
                              recordDate = selectedDate;
                              dateTec.text = dateFormat.format(selectedDate);
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.date_range),
                            labelText: Strings.recordDate,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                            enabled: !snapshot.data,
                            controller: docNoTec,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: Strings.documentNumber,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: truckNoTec,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: Strings.truckCode,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: refNoTec,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: Strings.reference,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(Strings.start.toUpperCase()),
                    onPressed: () {
                      final date = dateTec.text;
                      final docNo = docNoTec.text;
                      final truckNo = truckNoTec.text;
                      final refNo = refNoTec.text;
                      final cfCatch = bloc.validateEntry(date, docNo, truckNo, refNo);
                      if (cfCatch != null) {
                        Navigator.pushNamed(
                          context,
                          CatchingDetailScreen.route,
                          arguments: cfCatch,
                        );
                      }
                    },
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<bool>(
                      stream: bloc.isScanStream,
                      initialData: false,
                      builder: (context, snapshot) {
                        return Column(
                          children: <Widget>[
                            if (!snapshot.data)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FloatingActionButton(
                                  child: Icon(Icons.settings_overscan),
                                  onPressed: () async {
                                    ScanResult scanResult = await bloc.scan();
                                    if (scanResult.isSuccess == true) {
                                      dateTec.text = scanResult.date;
                                      docNoTec.text = scanResult.docNo.toString();
                                      truckNoTec.text = scanResult.truckNo;
                                    }
                                  },
                                ),
                              ),
                            if (snapshot.data)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FloatingActionButton(
                                  child: Icon(Icons.refresh),
                                  onPressed: () async {
                                    bloc.refresh();
                                    dateTec.text = dateFormat.format(recordDate);
                                    docNoTec.clear();
                                    truckNoTec.clear();
                                  },
                                ),
                              ),
                          ],
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: RaisedButton.icon(
                      icon: Icon(Icons.people_alt_outlined),
                      label: Text('Workers'),
                      onPressed: () async {
                        Navigator.pushNamed(
                          context,
                          CatchingWorkerScreen.route,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 0),
        Expanded(child: WorkerList()),
      ],
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class WorkerList extends StatefulWidget {
  @override
  _WorkerListState createState() => _WorkerListState();
}

class _WorkerListState extends State<WorkerList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Worker List", style: TextStyle(color: Colors.grey)),
        ),
        Divider(height: 0),
        Expanded(
          child: StreamBuilder<List<TempCfCatchWorker>>(
              stream: bloc.tempWorkerListStream,
              initialData: [],
              builder: (context, snapshot) {
                final list = snapshot.data;
                return ListView.separated(
                    separatorBuilder: (ctx, index) => Divider(height: 0),
                    itemCount: list.length,
                    itemBuilder: (ctx, position) {
                      final temp = list[position];

                      var hint = "";
                      if (temp.personStaffId == null) {
                        hint = "* ";
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          hint + temp.workerName,
                          style: TextStyle(color: temp.isFarmWorker == 1 ? Colors.red : null),
                        ),
                      );
                    });
              }),
        )
      ],
    );
  }
}
