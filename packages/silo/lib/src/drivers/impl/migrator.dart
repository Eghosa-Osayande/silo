import 'package:silo_common/silo_common.dart';

class SqliteMigrator implements Migrator {
  final DB db;

  SqliteMigrator({required this.db});

  @override
  String typeToTableName(Type t) {
    String input =
        t.toString().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return "silo_$input";
  }

  @override
  Future<void> createValueTable(String name) async {
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
    final result = await Expr(
      "SELECT count(*) as c FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    ).build(db).query();

    final count = result.first["c"] as num;

    return count > 0;
  }

  @override
  Future<Set<String>> getColumnNames(String table) async {
    final tableExpr = Quoted(table);
    final b = ExprBuilder(db);
    b.append("""PRAGMA table_info(?) """, [tableExpr]);

    final result = await db.query(b.sql, b.args);

    final colNames = result
        .map(
          (row) => row['name'].toString(),
        )
        .toList();

    return Set.from(colNames);
  }

  @override
  Future<void> autoMigrateSiloTable<T>(SiloTable<T> table) async {
    return db.transaction(
      (tx) async {
        final migrator = tx.migrator;
        final tableJson = table.toMap();

        final name = SiloRegistry.factoryName<T>();
        final keys = tableJson.keys;
        final primaryKey = table.tableKey();
        final tableExpr = Quoted(name);

        final exists = await migrator.hasTable(name);

        if (!exists) {
          await ExprBuilder(tx).append(
            "CREATE TABLE IF NOT EXISTS ? (? TEXT NOT NULL, PRIMARY KEY (?));",
            [tableExpr, Quoted(primaryKey), Quoted(primaryKey)],
          ).exec();
        }

        final cols = await migrator.getColumnNames(name);
        for (final key in keys) {
          if (cols.contains(key) || key == primaryKey) {
            continue;
          }
          await ExprBuilder(tx).append(
            "ALTER TABLE ? ADD ? TEXT",
            [tableExpr, Quoted(key), Quoted(primaryKey)],
          ).exec();
        }
      },
    );
  }
}
