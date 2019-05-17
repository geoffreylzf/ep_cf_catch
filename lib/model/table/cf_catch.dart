import 'package:ep_cf_catch/db/dao/cf_catch_detail_dao.dart';
import 'package:ep_cf_catch/model/table/cf_catch_detail.dart';
import 'package:ep_cf_catch/util/date_time_util.dart';
import 'package:flutter/material.dart';

class CfCatch {
  int id, companyId, locationId, printCount = 0, isDelete = 0, isUpload = 0;
  String recordDate, docNo, truckNo, refNo, uuid, timestamp;

  List<CfCatchDetail> cfCatchDetailList = [];

  CfCatch({
    this.id,
    this.companyId,
    this.locationId,
    this.recordDate,
    this.docNo,
    this.truckNo,
    this.refNo,
    this.printCount,
    this.uuid,
    this.isDelete,
    this.isUpload,
    this.timestamp,
    this.cfCatchDetailList,
  });

  CfCatch.db({
    @required this.companyId,
    @required this.locationId,
    @required this.recordDate,
    @required this.docNo,
    @required this.truckNo,
    @required this.refNo,
    @required this.uuid,
  });

  factory CfCatch.fromJson(Map<String, dynamic> json) {
    return CfCatch(
      id: json["id"],
      companyId: json["company_id"],
      locationId: json["location_id"],
      recordDate: json["record_date"],
      docNo: json["doc_no"],
      truckNo: json["truck_no"],
      refNo: json["ref_no"],
      printCount: json["print_count"],
      uuid: json["uuid"],
      isUpload: json["is_upload"],
      isDelete: json["is_delete"],
      timestamp: json["timestamp"],
      cfCatchDetailList: json["cf_catch_detail_list"] != null
          ? List<CfCatchDetail>.from(json["cf_catch_detail_list"]
              .map((dt) => CfCatchDetail.fromJson(dt)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "location_id": locationId,
        "record_date": recordDate,
        "doc_no": docNo,
        "truck_no": truckNo,
        "ref_no": refNo,
        "print_count": printCount,
        "uuid": uuid,
        "is_upload": isUpload,
        "is_delete": isDelete,
        "timestamp": timestamp,
        "cf_catch_detail_list":
            cfCatchDetailList != null && cfCatchDetailList.length > 0
                ? List<dynamic>.from(cfCatchDetailList.map((x) => x.toJson()))
                : [],
      };

  Map<String, dynamic> toDbJson() {
    return toJson()..remove("cf_catch_detail_list");
  }

  bool isDeleted() {
    return isDelete == 1;
  }

  bool isUploaded() {
    return isUpload == 1;
  }

  loadDetailList() async {
    cfCatchDetailList = await CfCatchDetailDao().getListByCfCatchId(id);
  }

  setCurrentTimestamp() {
    timestamp = DateTimeUtil().getCurrentTimestamp();
  }
}
