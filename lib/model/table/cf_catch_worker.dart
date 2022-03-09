import 'package:ep_cf_catch/model/table/temp_cf_catch_worker.dart';

class CfCatchWorker {
  int id, cfCatchId, personStaffId, isFarmWorker;
  String workerName;

  CfCatchWorker({
    this.id,
    this.cfCatchId,
    this.personStaffId,
    this.workerName,
    this.isFarmWorker,
  });

  CfCatchWorker.db({
    this.cfCatchId,
    this.personStaffId,
    this.workerName,
    this.isFarmWorker,
  });

  factory CfCatchWorker.fromJson(Map<String, dynamic> json) => CfCatchWorker(
        id: json["id"],
        cfCatchId: json["cf_catch_id"],
        personStaffId: json["person_staff_id"],
        workerName: json["worker_name"],
        isFarmWorker: json["is_farm_worker"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cf_catch_id": cfCatchId,
        "person_staff_id": personStaffId,
        "worker_name": workerName,
        "is_farm_worker": isFarmWorker,
      };

  static List<CfCatchWorker> fromTempWithCfCatchId(
      int cfCatchId, List<TempCfCatchWorker> tempList) {
    final List<CfCatchWorker> detailList = [];

    tempList.forEach((temp) {
      detailList.add(CfCatchWorker.db(
        cfCatchId: cfCatchId,
        personStaffId: temp.personStaffId,
        workerName: temp.workerName,
        isFarmWorker: temp.isFarmWorker,
      ));
    });

    return detailList;
  }
}
