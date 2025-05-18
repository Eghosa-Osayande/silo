import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/drivers/interfaces/migrator.dart';

mixin class SqliteMigrator<S extends DB> implements Migrator {
  @override
  Future<void> createTable() {
    // TODO: implement createTable
    throw UnimplementedError();
  }
}
