import 'package:silo/src/drivers/interfaces/database.dart';

import 'expression.dart';

class Quoted implements Expression {
  final String sql;

  Quoted(
    this.sql,
  );

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db).writeQuoted(sql);
  }
}
