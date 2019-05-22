import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/mixin/simple_alert_dialog_mixin.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/nav.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/catch_history/catch_history_screen.dart';
import 'package:ep_cf_catch/screen/catching/catching_screen.dart';
import 'package:ep_cf_catch/screen/home/home_bloc.dart';
import 'package:ep_cf_catch/screen/upload/upload_screen.dart';
import 'package:ep_cf_catch/widget/card_label_small.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SimpleAlertDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Provider<HomeBloc>(
      builder: (_) => HomeBloc(mixin: this),
      dispose: (_, value) => value.dispose(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Eng Peng Contract Farmer Catching"),
        ),
        body: HomeBody(),
        drawer: NavDrawerStart(),
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<HomeBloc>(context);
    bloc.loadCompany();
    return Column(
      children: [
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, CatchHistoryScreen.route);
                        },
                        icon: Icon(Icons.history),
                        label: Text(Strings.catchHistory.toUpperCase()),
                      ),
                      UploadCard(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RaisedButton.icon(
                    onPressed: () async {
                      int companyId = await SharedPreferencesModule().getCompanyId();

                      if (companyId != null) {
                        var company = await BranchDao().getCompanyById(companyId);
                        if (company != null) {
                          Navigator.pushNamed(
                            context,
                            CatchingScreen.route,
                            arguments: companyId,
                          );
                        } else {
                          bloc.showNoCompanyDialog();
                        }
                      } else {
                        bloc.showNoCompanyDialog();
                      }
                    },
                    icon: Icon(Icons.local_shipping),
                    label: Text(Strings.newCatching.toUpperCase()),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.blueGrey[700],
          child: ListTile(
            leading: Icon(
              Icons.business,
              color: Colors.white,
            ),
            title: StreamBuilder<Branch>(
                stream: bloc.companyStream,
                initialData: Branch(branchCode: "", branchName: ""),
                builder: (context, snapshot) {
                  var branch = snapshot.data;
                  if (branch == null) {
                    branch = Branch(branchCode: "", branchName: "");
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch.branchName, style: TextStyle(color: Colors.white)),
                      Text(
                        branch.branchCode,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  );
                }),
            trailing: StreamBuilder<PackageInfo>(
              stream: bloc.packageInfoStream,
              builder: (ctx, snapshot) {
                var ver = "";
                if (snapshot.hasData) {
                  ver = snapshot.data.version;
                }
                return Text(
                  "Version " + ver,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class UploadCard extends StatefulWidget {
  @override
  _UploadCardState createState() => _UploadCardState();
}

class _UploadCardState extends State<UploadCard> {
  @override
  Widget build(BuildContext context) {
    final homeBloc = Provider.of<HomeBloc>(context);
    homeBloc.loadNoUploadCount();
    return Card(
      color: Colors.white70,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardLabelSmall(Strings.pendingUpload),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_upload,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: StreamBuilder<int>(
                      stream: homeBloc.noUploadCountStream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: snapshot.data > 0
                                ? Theme.of(context).accentColor
                                : Theme.of(context).iconTheme.color,
                          ),
                        );
                      }),
                ),
              ],
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, UploadScreen.route);
              },
              child: Text(Strings.upload.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}
