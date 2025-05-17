import '../drivers/interfaces/database.dart';
import 'finisher.dart';
import 'hooks.dart';
import 'registry.dart';

import 'query_builder.dart';

class Silo<T>
    with
        SiloRegistry<Silo<T>>,
        SiloQueryBuilder<Silo<T>>,
        SiloFinisher<Silo<T>, T>,
        SiloHooks<Silo<T>, T> {
  Silo();

  static DB? _db;

  DB get db {
    if (_db == null) {
      throw Exception("DB has not been initialised yet");
    }
    return _db!;
  }

  Future<void> initDB(DB database) async {
    _db = database;
  }
}
