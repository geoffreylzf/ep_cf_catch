import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'company_bloc.dart';

class CompanyScreen extends StatefulWidget {
  static const String route = '/company';

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  @override
  Widget build(BuildContext context) {
    return Provider<CompanyBloc>(
      builder: (_) => CompanyBloc(),
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(title: Text("Company Selection")),
        body: CompanyList(),
      ),
    );
  }
}

class CompanyList extends StatefulWidget {
  @override
  _CompanyListState createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CompanyBloc>(context);
    return StreamBuilder<List<Branch>>(
        stream: bloc.coyListStream,
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
                    child: Icon(Icons.business),
                  ),
                  title: Text(list[position].branchName),
                  subtitle: Text(list[position].branchCode),
                  onTap: () async {
                    await bloc.setCompanyId(list[position].id);
                    Navigator.pop(context);
                  },
                ),
          );
        });
  }
}
