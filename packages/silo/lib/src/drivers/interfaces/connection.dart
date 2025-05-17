import 'database.dart';

abstract class Connection {
  Future<List<Map<String, Object?>>> query(String sql,
      [List<Object?> arguments]);

  Future<void> exec(String sql, [List<Object?> arguments]);

  Future<T> transaction<T>(Future<T> Function(DB db) action);
}
