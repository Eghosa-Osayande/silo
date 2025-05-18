abstract class Migrator {
  Future<void> createTypeTable(String name);

  Future<bool> hasTable(String name);

  String typeToTableName(Type t);
}
