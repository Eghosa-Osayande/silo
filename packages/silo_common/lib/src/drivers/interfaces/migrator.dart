import '/src/silo/models.dart';

abstract class Migrator {
  Future<void> createValueTable(String name);

  Future<void> autoMigrateSiloTable<T>(SiloTable<T> table);

  Future<bool> hasTable(String name);

  String typeToTableName(Type t);

  Future<Set<String>> getColumnNames(String tableName);
}
