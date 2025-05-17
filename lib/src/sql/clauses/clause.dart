import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/sql/expression/expression.dart';

const List<String> kCreateClauses = [
  'INSERT',
  'VALUES',
  'ON CONFLICT',
];

const List<String> kQueryClauses = [
  'SELECT',
  'FROM',
  'WHERE',
  'GROUP BY',
  'ORDER BY',
  'LIMIT',
  'FOR'
];

const List<String> kUpdateClauses = [
  'UPDATE',
  'SET',
  'WHERE',
];

const List<String> kDeleteClauses = [
  'DELETE',
  'FROM',
  'WHERE',
];


abstract mixin class Clause implements Expression {
  String get name;

  ExprBuilder builder(DB db) {
    final builder = ExprBuilder(db);
    return builder
      ..writeString("$name ")
      ..merge(build(db));
  }
}
