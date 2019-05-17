import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catch_history/catch_history_bloc.dart';
import 'package:ep_cf_catch/screen/catch_view/catch_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatchHistoryScreen extends StatefulWidget {
  static const String route = '/catchHistory';

  @override
  _CatchHistoryScreenState createState() => _CatchHistoryScreenState();
}

class _CatchHistoryScreenState extends State<CatchHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Provider<CatchHistoryBloc>(
      builder: (_) => CatchHistoryBloc(),
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.catchHistory),
        ),
        body: HistoryList(),
      ),
    );
  }
}

class HistoryList extends StatefulWidget {
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CatchHistoryBloc>(context);
    bloc.loadCfCatchList();
    return StreamBuilder<List<CfCatch>>(
        stream: bloc.cfCatchListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data;
          return ListView.separated(
            separatorBuilder: (ctx, index) => Divider(
                  height: 0,
                ),
            itemCount: list.length,
            itemBuilder: (ctx, position) => ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.local_shipping),
                  ),
                  trailing: Column(
                    children: <Widget>[
                      if (list[position].isUploaded())
                        Icon(Icons.cloud_upload),
                      if (list[position].isDeleted()) Icon(Icons.delete),
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder<Branch>(
                        future: bloc.getLocation(list[position].locationId),
                        initialData: Branch(branchName: "", branchCode: ""),
                        builder: (ctx, snapshot) {
                          return Text(
                            "${list[position].docNo} (${snapshot.data.branchName})",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          );
                        },
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.local_shipping,
                            size: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${list[position].truckNo} (${list[position].refNo})",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              list[position].timestamp,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () async {
                    Navigator.pushNamed(
                      context,
                      CatchViewScreen.route,
                      arguments: list[position].id,
                    );
                  },
                ),
          );
        });
  }
}
