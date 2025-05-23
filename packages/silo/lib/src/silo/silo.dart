import '../drivers/interfaces/database.dart';
import 'finisher.dart';
import 'query_builder.dart';

class Silo<T> with SiloQueryBuilder<Silo<T>, T>, SiloFinisher<Silo<T>, T> {
  Silo(this.db);

  final DB db;

}
