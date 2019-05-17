import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/cf_catch.dart';
import 'package:flutter/foundation.dart';

const _table = "cf_catch";

class CfCatchDao {
  static final _instance = CfCatchDao._internal();

  CfCatchDao._internal();

  factory CfCatchDao() => _instance;

  Future<int> insert(CfCatch cfCatch) async {
    final db = await Db().database;
    cfCatch.setCurrentTimestamp();
    final res = await db.insert(_table, cfCatch.toDbJson());
    return res;
  }

  Future<List<CfCatch>> getList() async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? res.map((c) => CfCatch.fromJson(c)).toList() : [];
  }

  Future<CfCatch> getById(int id) async {
    final db = await Db().database;
    final res = await db.query(_table, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? CfCatch.fromJson(res.first) : null;
  }

  Future<int> update(CfCatch cfCatch) async {
    final db = await Db().database;
    return await db.update(_table, cfCatch.toDbJson(),
        where: "id = ?", whereArgs: [cfCatch.id]);
  }

  Future<List<CfCatch>> getByUpload({@required int isUpload}) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: """is_upload = ?""",
      whereArgs: [isUpload],
    );
    return res.isNotEmpty ? res.map((c) => CfCatch.fromJson(c)).toList() : [];
  }
}
