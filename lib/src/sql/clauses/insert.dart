import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';

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
