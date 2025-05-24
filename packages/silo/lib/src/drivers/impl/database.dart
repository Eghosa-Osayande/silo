import 'package:silo/silo.dart';
import 'package:sqlite_async/sqlite_async.dart';

Future<DB> openDB(String path) => DefaultDB.open(path);

class DefaultDB extends DB {
  final SqliteDatabase database;
  final SqliteWriteContext? ctx;

  @override
  Dialector get dialector => SqliteDialector();

  @override
  Migrator get migrator => SqliteMigrator(db: this);

  DefaultDB(
    this.database, {
    this.ctx,
  });

  static Future<DefaultDB> open(
    String path,
  ) async {
    
    final database = SqliteDatabase(path: path);
    await database.initialize();
    return DefaultDB(database);
  }

  SqliteWriteContext get db => ctx ?? database;

  @override
  Future<void> exec(String sql, [List<Object?> arguments = const []]) async {
    await db.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> arguments = const [],
  ]) async {
    final resultSet = await db.getAll(sql, arguments);

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
      return database.writeTransaction(
        (tx) => action(DefaultDB(database, ctx: tx)),
      );
    }

    return action(DefaultDB(database, ctx: ctx));
  }

  @override
  Future<void> close() async {
    if (ctx != null) return;
    await database.close();
  }
}
