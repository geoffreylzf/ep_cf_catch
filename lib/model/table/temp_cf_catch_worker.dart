class TempCfCatchWorker {
  int id, personStaffId, isFarmWorker;
  String workerName;

  TempCfCatchWorker({
    this.id,
    this.personStaffId,
    this.workerName,
    this.isFarmWorker,
  });

  factory TempCfCatchWorker.fromJson(Map<String, dynamic> json) => TempCfCatchWorker(
      id: json["id"],
      personStaffId: json["person_staff_id"],
      workerName: json["worker_name"],
      isFarmWorker: json["is_farm_worker"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "person_staff_id": personStaffId,
        "worker_name": workerName,
        "is_farm_worker": isFarmWorker,
      };
}
