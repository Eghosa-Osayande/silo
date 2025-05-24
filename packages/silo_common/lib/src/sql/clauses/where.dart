import 'clause.dart';
import '../expression/expression.dart';
import '../../drivers/interfaces/database.dart';

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
