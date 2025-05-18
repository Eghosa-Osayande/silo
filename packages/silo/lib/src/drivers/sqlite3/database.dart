import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/drivers/sqlite/dialector.dart';
import 'package:silo/src/drivers/sqlite/migrator.dart';
import 'package:sqlite3/sqlite3.dart';

import 'conn.dart';

class Sqlite3DB extends DB
    with
        SqliteDialector,
        Sqlite3Connection<Sqlite3DB>,
        SqliteMigrator<Sqlite3DB> {
  //
  final Database db;

  Sqlite3DB(this.db);

  factory Sqlite3DB.fromPath(String path) {
    final db = sqlite3.open(path);
    return Sqlite3DB(db);
  }
}
