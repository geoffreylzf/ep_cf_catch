import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/log.dart';

const _table = "log";

class LogDao {
  static final _instance = LogDao._internal();

  LogDao._internal();

  factory LogDao() => _instance;

  Future<int> insert(Log log) async {
    final db = await Db().database;
    log.setCurrentTimestamp();
    final res = await db.insert(_table, log.toJson());
    return res;
  }

  Future<List<Log>> getAllByTask(String task) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: "task=?",
      whereArgs: [task],
      orderBy: "id DESC",
    );
    return res.isNotEmpty ? res.map((c) => Log.fromJson(c)).toList() : [];
  }
}
