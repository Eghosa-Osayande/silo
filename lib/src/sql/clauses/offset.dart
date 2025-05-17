import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

class Offset with Clause {
  final int offset;

  Offset(this.offset);

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db)
      ..writeString(" ")
      ..addVar(offset);
  }

  @override
  String get name => "OFFSET";
}
