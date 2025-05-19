import 'package:silo/silo.dart';
import 'package:sqlite3/sqlite3.dart';

class DBSqlite3 extends DB {
  final Database db;

  @override
  Dialector get dialector => SqliteDialector();

  @override
  Migrator get migrator => SqliteMigrator(db: this);

  DBSqlite3(this.db);

  factory DBSqlite3.open(
    String path, {
    String? vfs,
    OpenMode mode = OpenMode.readWriteCreate,
    bool uri = false,
    bool? mutex,
  }) {
    final db = sqlite3.open(
      path,
      mode: mode,
      mutex: mutex,
      uri: uri,
      vfs: vfs,
    );
    return DBSqlite3(db);
  }

  @override
  Future<void> exec(String sql, [List<Object?> arguments = const []]) async {
    return db.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> arguments = const [],
  ]) async {
    final resultSet = db.select(sql, arguments);

    final result = <Map<String, Object?>>[];
    for (final Row row in resultSet) {
      result.add(Map<String, Object?>.fromEntries(row.entries));
    }
    return result;
  }

  @override
  Future<T> transaction<T extends Object?>(
    Future<T> Function(DB tx) action,
  ) async {
    bool notTx = false;
    if (db.autocommit) {
      db.execute('BEGIN TRANSACTION');
      notTx = true;
    }

    try {
      final result = await action(this);
      if (notTx) db.execute('COMMIT');
      return result;
    } catch (e) {
      if (notTx) db.execute('ROLLBACK');
      rethrow;
    }
  }
}
