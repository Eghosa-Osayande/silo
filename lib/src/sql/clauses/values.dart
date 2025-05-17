import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

class Values with Clause {
  final Iterable<Expression> columns;
  final Iterable<dynamic> values;

  Values(this.columns, this.values);
  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);

    builder.merge(
      Expr(
        "(?) VALUES (?)",
        [columns, values],
      ).build(db),
    );

    return builder;
  }

  @override
  ExprBuilder builder(DB db) {
    return build(db);
  }

  @override
  String get name => "VALUES";
}
