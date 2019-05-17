

import 'package:ep_cf_catch/db/db.dart';

class UtilDao {
  static final _instance = UtilDao._internal();

  UtilDao._internal();

  factory UtilDao() => _instance;

  Future<int> getNoUploadCount() async {
    final db = await Db().database;
    final res = await db.rawQuery("""
    SELECT
      COUNT(*) as count
    FROM cf_catch
    WHERE is_upload = 0
    """);

    return res.isNotEmpty ? res.first['count'] : 0;
  }
}
