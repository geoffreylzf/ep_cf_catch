import 'package:ep_cf_catch/model/print_data.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/table/cf_catch_detail.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catch_view/catch_view_bloc.dart';
import 'package:ep_cf_catch/screen/print_preview/print_preview_screen.dart';
import 'package:ep_cf_catch/util/print_util.dart';
import 'package:ep_cf_catch/widget/simple_alert_dialog.dart';
import 'package:ep_cf_catch/widget/simple_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatchViewScreen extends StatefulWidget {
  static const String route = '/catchView';
  final int cfCatchId;

  CatchViewScreen(this.cfCatchId);

  @override
  _CatchViewScreenState createState() => _CatchViewScreenState();
}

class _CatchViewScreenState extends State<CatchViewScreen> {
  CatchViewBloc catchViewBloc;

  @override
  void initState() {
    super.initState();
    catchViewBloc = CatchViewBloc(cfCatchId: widget.cfCatchId);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<CatchViewBloc>(
      builder: (_) => catchViewBloc,
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.catchView),
          actions: [
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                _printCfCatch();
              },
            ),
            PopupMenuButton(
              onSelected: (v) {
                _deleteCfCatch();
              },
              itemBuilder: (ctx) {
                return [
                  PopupMenuItem(
                    value: 1,
                    child: Text(Strings.delete),
                  )
                ];
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            CatchInfo(),
            CatchListHeader(),
            Expanded(child: CatchDetailList()),
          ],
        ),
      ),
    );
  }

  _deleteCfCatch() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (catchViewBloc.getCfCatch().isUploaded()) {
          return SimpleAlertDialog(
            title: Strings.error,
            message: "Uploaded data cannot be delete.",
          );
        } else {
          return SimpleConfirmDialog(
            title: "Delete?",
            message: "This will delete the entered premix.",
            btnPositiveText: Strings.delete,
            vcb: () {
              catchViewBloc.deleteCfCatch();
            },
          );
        }
      },
    );
  }

  _printCfCatch() async {
    if (catchViewBloc.getCfCatch().isDeleted()) {
      showDialog(
          context: context,
          builder: (ctx) => SimpleAlertDialog(
                title: Strings.error,
                message: "Deleted data cannot be print.",
              ));
    } else {
      var text = await PrintUtil().generateCfCatchReceipt(widget.cfCatchId);
      var printData = PrintData(text: text);
      Navigator.of(context).pushNamed(
        PrintPreviewScreen.route,
        arguments: printData,
      );
    }
  }
}

class CatchListHeader extends StatefulWidget {
  @override
  _CatchListHeaderState createState() => _CatchListHeaderState();
}

class _CatchListHeaderState extends State<CatchListHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(flex: 1, child: ListHeader("#")),
            Expanded(flex: 1, child: ListHeader("House")),
            Expanded(flex: 1, child: ListHeader("Age")),
            Expanded(flex: 1, child: ListHeader("Qty")),
            Expanded(flex: 3, child: ListHeader(Strings.weightKg)),
            Expanded(flex: 1, child: ListHeader("Cage (Cover)")),
          ],
        ),
      ),
    );
  }
}

class CatchInfo extends StatefulWidget {
  @override
  _CatchInfoState createState() => _CatchInfoState();
}

class _CatchInfoState extends State<CatchInfo> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchViewBloc>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: StreamBuilder<CfCatch>(
          stream: bloc.cfCatchStream,
          builder: (context, snapshot) {
            var recordDate = "";
            var docNo = "";
            var truckNo = "";
            var refNo = "";
            if (snapshot.hasData) {
              final cfCatch = snapshot.data;
              recordDate = cfCatch.recordDate;
              docNo = cfCatch.docNo;
              truckNo = cfCatch.truckNo;
              refNo = cfCatch.refNo;
            }
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
                        future: bloc.getLocationCodeName(),
                        initialData: "",
                        builder: (ctx, snapshot) {
                          return Text(Strings.location + " : " + snapshot.data);
                        },
                      ),
                    ),
                    Expanded(
                        child: Text(Strings.recordDate + " : " + recordDate)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(Strings.documentNumber + " : " + docNo)),
                    Expanded(child: Text(Strings.truckCode + " : " + truckNo)),
                  ],
                ),
                SizedBox(
                    width: double.infinity,
                    child: Text(Strings.referenceNumber + " : " + refNo)),
              ],
            );
          }),
    );
  }
}

class CatchDetailList extends StatefulWidget {
  @override
  _CatchDetailListState createState() => _CatchDetailListState();
}

class _CatchDetailListState extends State<CatchDetailList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchViewBloc>(context);
    return StreamBuilder<List<CfCatchDetail>>(
      stream: bloc.cfCatchDetailListStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, position) {
            var no = list.length - position;
            var temp = list[position];
            var bgColor = Theme.of(ctx).scaffoldBackgroundColor;

            if (no % 2 == 0) {
              bgColor = Theme.of(ctx).highlightColor;
            }

            return Container(
              color: bgColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child:
                            Text(no.toString(), textAlign: TextAlign.center)),
                    Expanded(
                        flex: 1,
                        child: Text(temp.houseNo.toString(),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 1,
                        child: Text(temp.age.toString(),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 1,
                        child: Text(temp.qty.toString(),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 3,
                        child: Text(temp.weight.toStringAsFixed(2),
                            textAlign: TextAlign.center)),
                    Expanded(
                        flex: 1,
                        child: Text(
                            "${temp.cageQty.toString()} (${temp.coverQty.toString()})",
                            textAlign: TextAlign.center)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ListHeader extends StatelessWidget {
  final String text;

  ListHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
