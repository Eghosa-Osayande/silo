import 'dart:async';

import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/drivers/interfaces/dialector.dart';
import 'package:silo/src/drivers/interfaces/migrator.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'dialector.dart';
import 'migrator.dart';

class SiloDB extends DB {
  final SqliteDatabase database;
  final SqliteWriteContext? ctx;

  @override
  Dialector get dialector => SqliteDialector();

  @override
  Migrator get migrator => SqliteMigrator(db: this);

  SiloDB(
    this.database, {
    this.ctx,
  });

  static Future<SiloDB> fromPath(
    String path,
  ) async {
    final database = SqliteDatabase(path: path);
    await _run(() => database.initialize());
    return SiloDB(database);
  }

  static Future<SiloDB> fromDatabase(
    SqliteDatabase database,
  ) async {
    await _run(() => database.initialize());
    return SiloDB(database);
  }

  SqliteWriteContext get db => ctx ?? database;

  static FutureOr<T> _run<T>(FutureOr<T> Function() body) async {
    try {
      return await body();
    } catch (e) {
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  @override
  Future<void> exec(String sql, [List<Object?> arguments = const []]) async {
    await _run(() => db.execute(sql, arguments));
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> arguments = const [],
  ]) async {
    final resultSet = await _run(() => db.getAll(sql, arguments));

    final result = <Map<String, Object?>>[];
    for (final row in resultSet) {
      result.add(Map<String, Object?>.fromEntries(row.entries));
    }
    return result;
  }

  @override
  Future<T> transaction<T extends Object?>(
    Future<T> Function(DB) action,
  ) async {
    if (ctx == null) {
      return _run(() => database.writeTransaction(
            (tx) => action(SiloDB(database, ctx: tx)),
          ));
    }

    return action(SiloDB(database, ctx: ctx));
  }

  @override
  Future<void> close() async {
    if (ctx != null) return;
    await _run(() => database.close());
  }
}
