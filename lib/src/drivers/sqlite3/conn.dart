import 'package:silo/src/drivers/interfaces/connection.dart';
import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:sqlite3/sqlite3.dart';

mixin Sqlite3Connection on DB implements Connection {
  Database get db;

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
