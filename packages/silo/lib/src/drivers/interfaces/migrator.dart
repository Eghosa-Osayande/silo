abstract class Migrator {
  Future<void> createTypeTable<T>([String? name]);

  Future<bool> hasTable<T>([String? name]);

  String typeToTableName(Type t);
}
