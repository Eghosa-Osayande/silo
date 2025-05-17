import 'clause.dart';
import '../expression/expression.dart';
import '../../drivers/interfaces/database.dart';

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
