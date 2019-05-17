import 'package:ep_cf_catch/util/date_time_util.dart';
import 'package:flutter/material.dart';

class Log {
  static const logTaskUpload = "UPLOAD";

  int id;
  String task, remark, timestamp;

  Log({
    this.id,
    this.task,
    this.remark,
    this.timestamp,
  });

  Log.dbInsert({
    @required this.task,
    @required this.remark,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        id: json["id"],
        task: json["task"],
        remark: json["remark"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {"id": id, "task": task, "remark": remark, "timestamp": timestamp};

  setCurrentTimestamp() {
    timestamp = DateTimeUtil().getCurrentTimestamp();
  }
}
