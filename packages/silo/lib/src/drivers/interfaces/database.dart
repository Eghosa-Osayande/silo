import 'connection.dart';
import 'dialector.dart';
import 'migrator.dart';

abstract mixin class DB implements Connection {
  Migrator get migrator;
  Dialector get dialector;
}
