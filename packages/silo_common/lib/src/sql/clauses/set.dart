import '../../drivers/interfaces/database.dart';
import 'clause.dart';
import '../expression/expression.dart';

class SetClause with Clause {
  final Expression? table;
  final List<Expression> updates;
  final bool isExcluded;

  SetClause(
    this.updates, {
    this.isExcluded = false,
    this.table,
  });
  @override
  ExprBuilder build(DB db) {
    final b = ExprBuilder(db);

    for (var k in updates) {
      b.merge(k.build(db));
      b.writeString(", ");
    }
    b.trimTrailingComma();

    return b;
  }

  @override
  ExprBuilder builder(DB db) {
    final b = ExprBuilder(db);
    if (isExcluded) {
      b.writeString("DO UPDATE SET ");
    } else {
      b.writeString("SET ");
    }
    b.merge(build(db));
    return b;
  }

  @override
  String get name => "SET";
}
