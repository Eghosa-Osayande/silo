import '../interfaces/connection.dart';
import '../interfaces/database.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

mixin Sqlite3Connection<S extends Sqlite3DB> implements Connection {
  Database get _db => (this as S).db;

  @override
  Future<void> exec(String sql, [List<Object?> arguments = const []]) async {
    return _db.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> arguments = const [],
  ]) async {
    final resultSet = _db.select(sql, arguments);

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
    if (_db.autocommit) {
      _db.execute('BEGIN TRANSACTION');
      notTx = true;
    }

    try {
      final result = await action(this as S);
      if (notTx) _db.execute('COMMIT');
      return result;
    } catch (e) {
      if (notTx) _db.execute('ROLLBACK');
      rethrow;
    }
  }
}
