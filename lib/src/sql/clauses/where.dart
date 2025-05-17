import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

class Where with Clause {
  final List<Expression> conditions;

  Where(this.conditions);
  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);
    for (final condition in conditions) {
      builder
        ..merge(condition.build(db))
        ..writeString(" ");
    }

    builder.trimRight();

    return builder;
  }

  @override
  String get name => "WHERE";
}
