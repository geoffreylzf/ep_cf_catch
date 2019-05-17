import 'package:ep_cf_catch/model/table/cf_catch.dart';

class UploadBody {
  List<CfCatch> cfCatchList;

  UploadBody({this.cfCatchList});

  Map<String, dynamic> toJson() => {
        "cf_catch_list": cfCatchList != null && cfCatchList.length > 0
            ? List<dynamic>.from(cfCatchList.map((x) => x.toJson()))
            : [],
      };
}
