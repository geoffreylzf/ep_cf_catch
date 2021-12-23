import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/cf_catch_worker.dart';

const _table = "cf_catch_worker";

class CfCatchWorkerDao {
  static final _instance = CfCatchWorkerDao._internal();

  CfCatchWorkerDao._internal();

  factory CfCatchWorkerDao() => _instance;

  Future<int> insert(CfCatchWorker cfCatchWorker) async {
    var db = await Db().database;
    var res = await db.insert(_table, cfCatchWorker.toJson());
    return res;
  }

  Future<List<CfCatchWorker>> getListByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? res.map((c) => CfCatchWorker.fromJson(c)).toList() : [];
  }
}
