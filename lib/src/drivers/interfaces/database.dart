import 'package:silo/src/drivers/interfaces/connection.dart';
import 'package:silo/src/drivers/interfaces/dialector.dart';

import 'config.dart';

abstract class DB implements Dialector, Connection {
  Config get config;
}
