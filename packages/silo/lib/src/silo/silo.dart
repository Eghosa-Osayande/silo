import '../drivers/interfaces/database.dart';
import 'finisher.dart';
import 'query_builder.dart';

class Silo<T>
    with
        SiloQueryBuilder<Silo<T>>,
        SiloFinisher<Silo<T>, T> {
  Silo(DB db) : this._db = db;

  DB? _db;
  String? name;

  DB? get db {
    return _db;
  }

  Silo setDB(DB tx) {
    _db = tx;
    return this;
  }

  Silo collection(String name) {
    this.name = name;
    return this;
  }
}
