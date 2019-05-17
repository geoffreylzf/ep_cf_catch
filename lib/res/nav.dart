
import 'package:ep_cf_catch/db/dao/util_dao.dart';
import 'package:ep_cf_catch/model/user.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/res/string.dart';
import 'package:ep_cf_catch/screen/company/company_screen.dart';
import 'package:ep_cf_catch/screen/housekeeping/housekeeping_screen.dart';
import 'package:ep_cf_catch/screen/login/login_screen.dart';
import 'package:ep_cf_catch/screen/upload/upload_screen.dart';
import 'package:ep_cf_catch/widget/simple_alert_dialog.dart';
import 'package:ep_cf_catch/widget/simple_confirm_dialog.dart';
import 'package:flutter/material.dart';

class NavDrawerStart extends StatelessWidget {
  @override
  Widget build(BuildContext mainContext) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: FutureBuilder<User>(
                future: SharedPreferencesModule().getUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            snapshot.data.username,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    );
                  }
                  return Container();
                }),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text(Strings.company),
            onTap: () {
              Navigator.pop(mainContext);
              Navigator.pushNamed(mainContext, CompanyScreen.route);
            },
          ),
          ListTile(
            leading: Icon(Icons.view_quilt),
            title: Text(Strings.housekeeping),
            onTap: () {
              Navigator.pop(mainContext);
              Navigator.pushNamed(mainContext, HousekeepingScreen.route);
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text(Strings.upload),
            onTap: () {
              Navigator.pop(mainContext);
              Navigator.pushNamed(mainContext, UploadScreen.route);
            },
          ),

          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings.logout),
            onTap: () async {
              final noUploadCount = await UtilDao().getNoUploadCount();
              print(noUploadCount);
              if (noUploadCount != 0) {
                showDialog(
                    context: mainContext,
                    builder: (BuildContext context) {
                      return SimpleAlertDialog(
                        title: Strings.error,
                        message:
                        "Got pending upload data, please upload before logout.",
                      );
                    });
              } else {
                showDialog(
                    context: mainContext,
                    builder: (BuildContext context) {
                      return SimpleConfirmDialog(
                        title: "Logout?",
                        message: "Connection is needed for login after logout.",
                        btnPositiveText: Strings.logout,
                        vcb: () async {
                          await SharedPreferencesModule().clearUser();
                          Navigator.pushReplacementNamed(
                              mainContext, LoginScreen.route);
                        },
                      );
                    });
              }
            },
          ),
        ],
      ),
    );
  }
}
