import 'connection.dart';
import 'dialector.dart';

import 'config.dart';

abstract class DB implements Dialector, Connection {
  Config get config;
}
