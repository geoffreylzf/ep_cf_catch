import 'package:ep_cf_catch/model/print_data.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:ep_cf_catch/model/user.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';
import 'package:ep_cf_catch/screen/catch_history/catch_history_screen.dart';
import 'package:ep_cf_catch/screen/catch_view/catch_view_screen.dart';
import 'package:ep_cf_catch/screen/catching/catching_screen.dart';
import 'package:ep_cf_catch/screen/catching_detail/catching_detail_screen.dart';
import 'package:ep_cf_catch/screen/company/company_screen.dart';
import 'package:ep_cf_catch/screen/home/home_screen.dart';
import 'package:ep_cf_catch/screen/housekeeping/housekeeping_screen.dart';
import 'package:ep_cf_catch/screen/login/login_screen.dart';
import 'package:ep_cf_catch/screen/print_preview/print_preview_screen.dart';
import 'package:ep_cf_catch/screen/update_app_ver/update_app_ver_screen.dart';
import 'package:ep_cf_catch/screen/upload/upload_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eng Peng Contract Farmer Catching',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: FutureBuilder<User>(
        future: SharedPreferencesModule().getUser(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return HomeScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        LoginScreen.route: (ctx) => LoginScreen(),
        HomeScreen.route: (ctx) => HomeScreen(),
        HousekeepingScreen.route: (ctx) => HousekeepingScreen(),
        CompanyScreen.route: (ctx) => CompanyScreen(),
        UploadScreen.route: (ctx) => UploadScreen(),
        UpdateAppVerScreen.route: (ctx) => UpdateAppVerScreen(),
        CatchHistoryScreen.route: (ctx) => CatchHistoryScreen(),
        CatchingScreen.route: (ctx) {
          var companyId = ModalRoute.of(ctx).settings.arguments as int;
          return CatchingScreen(companyId);
        },
        CatchingDetailScreen.route: (ctx) {
          var cfCatch = ModalRoute.of(ctx).settings.arguments as CfCatch;
          return CatchingDetailScreen(cfCatch);
        },
        PrintPreviewScreen.route: (ctx) {
          var printData = ModalRoute.of(ctx).settings.arguments as PrintData;
          return PrintPreviewScreen(printData);
        },
        CatchViewScreen.route: (ctx) {
          var cfCatchId = ModalRoute.of(ctx).settings.arguments as int;
          return CatchViewScreen(cfCatchId);
        },
      },
    );
  }
}
