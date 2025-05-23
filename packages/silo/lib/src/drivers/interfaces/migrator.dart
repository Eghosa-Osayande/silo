import 'package:silo/src/silo/models.dart';

abstract class Migrator {
  Future<void> createJsonTable(String name);

  Future<void> autoMigrateSiloTable<T>(SiloTable<T> table);

  Future<bool> hasTable(String name);

  String typeToTableName(Type t);
}
