import 'package:ep_cf_catch/model/table/temp_cf_catch_detail.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TempList extends StatefulWidget {
  @override
  _TempListState createState() => _TempListState();
}

class _TempListState extends State<TempList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchingDetailBloc>(context);
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: ListHeader("#")),
                Expanded(flex: 2, child: ListHeader("H#")),
                Expanded(flex: 3, child: ListHeader(Strings.weightKg))
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

                    return Container(
                      color: bgColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(no.toString(),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(temp.houseNo.toString(),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 3,
                                child: Text(temp.weight.toStringAsFixed(2),
                                    textAlign: TextAlign.end))
                          ],
                        ),
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
