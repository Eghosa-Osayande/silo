import 'package:silo/src/silo/silo.dart';

import 'connection.dart';
import 'dialector.dart';
import 'migrator.dart';

abstract mixin class DB implements Connection {
  Migrator get migrator;
  Dialector get dialector;

  Silo<T> silo<T>() => Silo(this);
}
