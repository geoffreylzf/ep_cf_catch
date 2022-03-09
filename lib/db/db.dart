import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'db_sql.dart';

const _version = 3;
const _dbName = "ep_cf_ca.db";

class Db {
  static final _instance = Db._internal();

  factory Db() => _instance;

  Db._internal();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        await db.execute(DbSql.createBranchTable);
        await db.execute(DbSql.createTempCfCatchDetailTable);
        await db.execute(DbSql.createCfCatchTable);
        await db.execute(DbSql.createCfCatchDetailTable);
        await db.execute(DbSql.createLogTable);

        await db.execute(DbSql.createCfCatchWorkerTable);
        await db.execute(DbSql.createTempCfCatchWorkerTable);
        await db.execute(DbSql.createPersonStaffTable);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion <= 1) {
          await db.execute(DbSql.createCfCatchWorkerTable);
          await db.execute(DbSql.createTempCfCatchWorkerTable);
          await db.execute(DbSql.createPersonStaffTable);
        }

        if (oldVersion <= 2) {
          await db.execute("ALTER TABLE cf_catch_worker ADD COLUMN is_farm_worker INTEGER DEFAULT 0");
          await db.execute("ALTER TABLE temp_cf_catch_worker ADD COLUMN is_farm_worker INTEGER DEFAULT 0");
        }
      },
    );
  }
}
