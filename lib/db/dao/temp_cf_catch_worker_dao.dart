import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_worker.dart';

const _table = "temp_cf_catch_worker";

class TempCfCatchWorkerDao {
  static final _instance = TempCfCatchWorkerDao._internal();

  TempCfCatchWorkerDao._internal();

  factory TempCfCatchWorkerDao() => _instance;

  Future<int> insert(TempCfCatchWorker temp) async {
    var db = await Db().database;
    var res = await db.insert(_table, temp.toJson());
    return res;
  }

  Future<List<TempCfCatchWorker>> getList() async {
    final db = await Db().database;
    final res = await db.query(_table, orderBy: "id desc");
    return res.isNotEmpty
        ? res.map((c) => TempCfCatchWorker.fromJson(c)).toList()
        : [];
  }

  Future<int> deleteById(int id) async {
    var db = await Db().database;
    return await db.delete(_table, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var db = await Db().database;
    return await db.delete(_table);
  }
}
