import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

class Limit with Clause {
  final int limit;

  Limit(this.limit);

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db)
      ..writeString(" ")
      ..addVar(limit);
  }

  @override
  String get name => "LIMIT";
}
