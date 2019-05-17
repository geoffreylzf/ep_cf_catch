class DbSql {
  static final createBranchTable = """
      CREATE TABLE `branch` (
      `id` INTEGER PRIMARY KEY, 
      `branch_code` TEXT, 
      `branch_name` TEXT,
      `company_id` INTEGER);
  """;

  static final createCfCatchTable = """
      CREATE TABLE `cf_catch` (
      `id` INTEGER PRIMARY KEY,
      `company_id` INTEGER,
      `location_id` INTEGER,
      `record_date` TEXT,
      `doc_no` TEXT,
      `truck_no` TEXT,
      `ref_no` TEXT, 
      `print_count` INTEGER, 
      `uuid` TEXT,
      `is_delete` INTEGER DEFAULT 0,
      `is_upload` INTEGER DEFAULT 0,
      `timestamp` TIMESTAMP);
  """;

  static final createCfCatchDetailTable = """
      CREATE TABLE `cf_catch_detail` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `cf_catch_id` INTEGER,
      `house_no` INTEGER,
      `weight` REAL,
      `qty` INTEGER,
      `cage_qty` INTEGER,
      `cover_qty` INTEGER,
      `is_bt` INTEGER);
      """;

  static final createTempCfCatchDetailTable = """
      CREATE TABLE `temp_cf_catch_detail` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `house_no` INTEGER,
      `weight` REAL,
      `qty` INTEGER,
      `cage_qty` INTEGER,
      `cover_qty` INTEGER,
      `is_bt` INTEGER);
      """;

  static final createLogTable = """
      CREATE TABLE `log` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `task` TEXT,
      `remark` TEXT,
      `timestamp` TIMESTAMP);
      """;
}
