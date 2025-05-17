import '../../drivers/interfaces/database.dart';
import 'clause.dart';
import '../expression/expression.dart';

class Insert with Clause {
  final Expression table;
  

  Insert(this.table);

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db)
      ..writeString("INTO ")
      ..merge(table.build(db));

    return builder;
  }

  @override
  String get name => "INSERT";
}
