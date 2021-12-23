import 'package:ep_cf_catch/db/db.dart';
import 'package:ep_cf_catch/model/table/person_staff.dart';

const _table = "person_staff";

class PersonStaffDao {
  static final _instance = PersonStaffDao._internal();

  PersonStaffDao._internal();

  factory PersonStaffDao() => _instance;

  Future<List<PersonStaff>> getPersonStaffListByFilter(String filter) async {
    final db = await Db().database;
    final res = await db.query(
      _table,
      where: "person_code||person_name LIKE '%$filter%'",
      orderBy: "person_name",
    );
    return res.isNotEmpty ? res.map((c) => PersonStaff.fromJson(c)).toList() : [];
  }

  Future<int> getCount() async {
    final db = await Db().database;
    final res = await db.rawQuery("""
    SELECT
      COUNT(*) as count
    FROM person_staff
    """);
    return res.isNotEmpty ? res.first['count'] : 0;
  }

  Future<int> deleteAll() async {
    var db = await Db().database;
    var res = await db.delete(_table);
    return res;
  }

  Future<int> insert(PersonStaff personStaff) async {
    var db = await Db().database;
    var res = await db.insert(_table, personStaff.toJson());
    return res;
  }
}
