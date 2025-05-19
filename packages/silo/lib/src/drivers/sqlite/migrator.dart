import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/drivers/interfaces/migrator.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/sql/expression/quoted.dart';

class SqliteMigrator implements Migrator {
  final DB db;

  SqliteMigrator({required this.db});

  String _cleanString(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  @override
  String typeToTableName(Type t) {
    return "_silo_${_cleanString(t.toString()).toLowerCase()}";
  }

  @override
  Future<void> createJsonTable(String name) async {
    final tableExpr = Quoted(name);

    final b = ExprBuilder(db);

    b.append(
      """
CREATE TABLE IF NOT EXISTS ? (
  ? TEXT NOT NULL,
  ? TEXT,
  ? DATETIME NOT NULL,
  ? DATETIME NOT NULL,
  ? DATETIME,
  PRIMARY KEY (?)
); 
    """,
      [
        tableExpr,
        Quoted("key"),
        Quoted("value"),
        Quoted("created_at"),
        Quoted("updated_at"),
        Quoted("expired_at"),
        Quoted("key"),
      ],
    );

    await db.exec(b.sql, b.args);
  }

  @override
  Future<bool> hasTable(String name) async {
    final tableName = name;
    final b = Expr(
      "SELECT count(*) as c FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    ).build(db);

    final result = await db.query(b.sql, b.args);

    final count = result.first["c"] as num;

    return count > 0;
  }
}
