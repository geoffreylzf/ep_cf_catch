import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/cf_catch_detail.dart';

const _table = "cf_catch_detail";

class CfCatchDetailDao {
  static final _instance = CfCatchDetailDao._internal();

  CfCatchDetailDao._internal();

  factory CfCatchDetailDao() => _instance;

  Future<int> insert(CfCatchDetail cfCatchDetail) async {
    var db = await Db().database;
    var res = await db.insert(_table, cfCatchDetail.toJson());
    return res;
  }

  Future<List<CfCatchDetail>> getListByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? res.map((c) => CfCatchDetail.fromJson(c)).toList() : [];
  }

  Future<List<int>> getHouseListByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      columns: ["DISTINCT(house_no) as house_no"],
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
      orderBy: "house_no",
    );
    return res.isNotEmpty ? res.map((c) => c["house_no"] as int).toList() : [];
  }

  Future<int> getTtlQtyByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      columns: ["SUM(qty) as qty"],
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
    );
    return res.isNotEmpty ? res.first['qty'] : 0;
  }

  Future<int> getTtlCageQtyByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      columns: ["SUM(cage_qty) as cage_qty"],
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
    );
    return res.isNotEmpty ? res.first['cage_qty'] : 0;
  }

  Future<int> getTtlCoverQtyByCfCatchId(int cfCatchId) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      columns: ["SUM(cover_qty) as cover_qty"],
      where: "cf_catch_id = ?",
      whereArgs: [cfCatchId],
    );
    return res.isNotEmpty ? res.first['cover_qty'] : 0;
  }

  Future<List<CfCatchDetail>> getListByCfCatchIdHouseNo(int cfCatchId, int houseNo) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: "cf_catch_id = ? AND house_no = ?",
      whereArgs: [cfCatchId, houseNo],
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? res.map((c) => CfCatchDetail.fromJson(c)).toList() : [];
  }

  Future<List<int>> getAgeListByCfCatchIdHouseNo(int cfCatchId, int houseNo) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      columns: ["DISTINCT(age) as age"],
      where: "cf_catch_id = ? AND house_no = ?",
      whereArgs: [cfCatchId, houseNo],
      orderBy: "age",
    );
    return res.isNotEmpty ? res.map((c) => c["age"] as int).toList() : [];
  }
}
