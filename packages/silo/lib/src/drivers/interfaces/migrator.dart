abstract class Migrator {
  Future<void> createJsonTable(String name);

  Future<bool> hasTable(String name);

  String typeToTableName(Type t);
}
