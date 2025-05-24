import 'clauses/clause.dart';
import 'expression/expression.dart';
import '../drivers/interfaces/database.dart';

class Statement {
  final Map<String, Clause> clauses;

  Statement({required this.clauses});

  addClauses(List<Clause> c) {
    for (var clause in c) {
      clauses[clause.name] = clause;
    }
  }

  ExprBuilder buildCondition(DB db) {
    final whereClause = clauses["WHERE"];
    final builder = ExprBuilder(db);

    if (whereClause != null) {
      builder.merge(whereClause.build(db));
    }

    return builder;
  }

  ExprBuilder buildClauses(DB db, List<String> clauseNames) {
    final builder = ExprBuilder(db);
    for (var clauseName in clauseNames) {
      final clause = clauses[clauseName];
      if (clause == null) continue;

      builder.merge(clause.builder(db));
      builder.writeString(" ");
    }
    return builder;
  }
}
