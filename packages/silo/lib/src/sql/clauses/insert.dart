import '../../drivers/interfaces/database.dart';
import 'clause.dart';
import '../expression/expression.dart';

class Insert with Clause {
  final Expression table;
  final bool orReplace;

  Insert(
    this.table, {
    this.orReplace = false,
  });

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);

    if (orReplace) {
      builder.writeString("OR REPLACE ");
    }
    builder
      ..writeString("INTO ")
      ..merge(table.build(db));

    return builder;
  }

  @override
  String get name => "INSERT";
}
