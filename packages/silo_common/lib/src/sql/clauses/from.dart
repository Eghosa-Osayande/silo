import '../../drivers/interfaces/database.dart';
import 'clause.dart';
import '../expression/expression.dart';

class From with Clause {
  final Expression table;
  final List<Expression> joins;

  From(this.table, this.joins);

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db).merge(table.build(db));

    for (var join in joins) {
      builder
        ..writeString(" ")
        ..merge(join.build(db));
    }

    return builder;
  }

  @override
  String get name => "FROM";
}
