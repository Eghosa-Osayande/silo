import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

import 'clause.dart';

class Select with Clause {
  final List<Expression>? omissions;
  final List<Expression> selections;

  Select(
    this.selections,
    this.omissions,
  );

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);
    var initialSelection = selections;

    final selectedColsMap = <String, List<dynamic>>{};
    for (var expr in initialSelection) {
      final exprResult = expr.build(db);
      selectedColsMap[exprResult.sql] = exprResult.args;
    }

    if (omissions != null) {
      for (var omited in omissions!) {
        final exprResult = omited.build(db);
        selectedColsMap.remove(exprResult.sql);
      }
    }

    for (var expr in selectedColsMap.entries) {
      builder.append("${expr.key}, ", expr.value);
    }

    builder.trimRight().trimSuffix(",");

    return builder;
  }

  @override
  String get name => "SELECT";
}
