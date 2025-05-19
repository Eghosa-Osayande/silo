import 'package:silo/silo.dart';
import 'package:sqflite/sqflite.dart';

class DBSqflite extends DB {
  final DatabaseExecutor db;

  @override
  Dialector get dialector => SqliteDialector();

  @override
  Migrator get migrator => SqliteMigrator(db: this);

  DBSqflite(this.db);

  @override
  Future<void> exec(String sql, [List<Object?> arguments = const []]) async {
    return db.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> arguments = const [],
  ]) async {
    return db.rawQuery(sql, arguments);
  }

  @override
  Future<T> transaction<T extends Object?>(
    Future<T> Function(DB tx) action,
  ) async {
    return db.database.transaction<T>(
      (txn) async {
        return action(DBSqflite(txn));
      },
    );
  }

  @override
  Future<void> close() async {
    await db.database.close();
  }
}
