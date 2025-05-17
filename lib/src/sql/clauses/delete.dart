import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';

class Delete with Clause {
  Delete();

  @override
  ExprBuilder build(DB db) {
    final b = ExprBuilder(db);
    return b;
  }

  @override
  String get name => "DELETE";
}
