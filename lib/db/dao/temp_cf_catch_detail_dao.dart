import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/temp_cf_catch_detail.dart';
import 'package:ep_cf_catch/model/temp_total.dart';

const _table = "temp_cf_catch_detail";

class TempCfCatchDetailDao {
  static final _instance = TempCfCatchDetailDao._internal();

  TempCfCatchDetailDao._internal();

  factory TempCfCatchDetailDao() => _instance;

  Future<int> insert(TempCfCatchDetail temp) async {
    var db = await Db().database;
    var res = await db.insert(_table, temp.toJson());
    return res;
  }

  Future<List<TempCfCatchDetail>> getList() async {
    final db = await Db().database;
    final res = await db.query(_table, orderBy: "id desc");
    return res.isNotEmpty
        ? res.map((c) => TempCfCatchDetail.fromJson(c)).toList()
        : [];
  }

  Future<int> deleteById(int id) async {
    var db = await Db().database;
    return await db.delete(_table, where: "id = ?", whereArgs: [id]);
  }

  Future<TempTotal> getTotal() async{
    final db = await Db().database;
    final res = await db.rawQuery("""
    SELECT
      SUM(qty) AS ttl_qty,
      SUM(weight) AS ttl_weight,
      SUM(cage_qty) AS ttl_cage,
      SUM(cover_qty) AS ttl_cover
    FROM temp_cf_catch_detail
    """);
    return res.isNotEmpty ? TempTotal.fromJson(res.first) : null;
  }

  Future<int> deleteAll() async {
    var db = await Db().database;
    return await db.delete(_table);
  }
}
