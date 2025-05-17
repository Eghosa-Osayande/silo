import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

import 'set.dart';

class OnConflict with Clause {
  final List<Expression> columns;
  final SetClause? doUpdate;

  OnConflict(this.columns, {this.doUpdate});

  @override
  ExprBuilder build(DB db) {
    final b = ExprBuilder(db);
    b.append(
      "(?)",
      [columns],
    );
    if (doUpdate != null) {
      b.writeString(" ");
      b.merge(doUpdate!.builder(db));
    }
    return b;
  }

  @override
  String get name => "ON CONFLICT";
}
