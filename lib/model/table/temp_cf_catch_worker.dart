class TempCfCatchWorker {
  int id, personStaffId;
  String workerName;

  TempCfCatchWorker({
    this.id,
    this.personStaffId,
    this.workerName,
  });

  factory TempCfCatchWorker.fromJson(Map<String, dynamic> json) => TempCfCatchWorker(
    id: json["id"],
    personStaffId: json["person_staff_id"],
    workerName: json["worker_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "person_staff_id": personStaffId,
    "worker_name": workerName,
  };
}
