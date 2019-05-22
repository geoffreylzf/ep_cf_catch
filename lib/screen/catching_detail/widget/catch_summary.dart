import 'package:ep_cf_catch/model/print_data.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_detail.dart';
import 'package:ep_cf_catch/model/temp_total.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_bloc.dart';
import 'package:ep_cf_catch/screen/print_preview/print_preview_screen.dart';
import 'package:ep_cf_catch/util/print_util.dart';
import 'package:ep_cf_catch/widget/simple_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatchSummary extends StatefulWidget {
  @override
  _CatchSummaryState createState() => _CatchSummaryState();
}

class _CatchSummaryState extends State<CatchSummary> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingDetailBloc>(context);
    return Column(
      children: <Widget>[
        Padding(
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
                    children: <Widget>[
                      Expanded(
                        child: FutureBuilder<String>(
                          future: bloc.getLocationCodeName(),
                          initialData: "",
                          builder: (ctx, snapshot) {
                            return Text(
                                Strings.location + " : " + snapshot.data);
                          },
                        ),
                      ),
                      Expanded(
                          child: Text(Strings.recordDate + " : " + recordDate)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: Text(Strings.documentNumber + " : " + docNo)),
                      Expanded(
                          child: Text(Strings.truckCode + " : " + truckNo)),
                    ],
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: Text(Strings.referenceNumber + " : " + refNo)),
                ],
              );
            },
          ),
        ),
        Container(
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
        ),
        Expanded(
          child: StreamBuilder<List<TempCfCatchDetail>>(
              stream: bloc.tempListStream,
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

                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: PageStorageKey(list[position].id.toString()),
                      onDismissed: (direction) {
                        bloc.deleteDetail(list[position].id);
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
                                title: Text("Delete this data?"),
                                content: Text(
                                    "Weight : ${temp.weight.toStringAsFixed(2)} Kg"),
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
                      child: Container(
                        color: bgColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text(no.toString(),
                                      textAlign: TextAlign.center)),
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
                      ),
                    );
                  },
                );
              }),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text("Swipe left to delete"),
        ),
        Container(
          color: Theme.of(context).primaryColorDark,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: StreamBuilder<TempTotal>(
                stream: bloc.tempTotalStream,
                builder: (context, snapshot) {
                  var qty = 0, weight = 0.00, cage = 0, cover = 0;
                  if (snapshot.hasData) {
                    final ttl = snapshot.data;
                    qty = ttl.ttlQty ?? 0;
                    weight = ttl.ttlWeight ?? 0;
                    cage = ttl.ttlCage ?? 0;
                    cover = ttl.ttlCover ?? 0;
                  }
                  return Row(
                    children: [
                      Expanded(flex: 1, child: ListHeader("")),
                      Expanded(flex: 1, child: ListHeader("")),
                      Expanded(flex: 1, child: ListHeader(qty.toString())),
                      Expanded(
                          flex: 3,
                          child: ListHeader(weight.toStringAsFixed(2))),
                      Expanded(flex: 1, child: ListHeader("$cage ($cover)")),
                    ],
                  );
                }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton.icon(
              icon: Icon(Icons.save),
              label: Text(Strings.save.toUpperCase()),
              onPressed: () {
                bloc.validate().then((r) {
                  if (r) {
                    _confirmSave(context, bloc);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  _confirmSave(BuildContext mainContext, CatchingDetailBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleConfirmDialog(
          title: "Save?",
          message: "Edit is not allow after save.",
          btnPositiveText: Strings.save,
          vcb: () async {
            final cfCatchId = await bloc.saveCatch();
            final text = await PrintUtil().generateCfCatchReceipt(cfCatchId);
            final printData = PrintData(text: text);
            Navigator.of(mainContext).pop();
            Navigator.of(mainContext)
                .pushReplacementNamed(PrintPreviewScreen.route, arguments: printData);
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
