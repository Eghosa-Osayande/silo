import 'clause.dart';
import '../expression/expression.dart';
import '../../drivers/interfaces/database.dart';

class Limit with Clause {
  final int limit;

  Limit(this.limit);

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db)
      ..writeString(" ")
      ..addVar(limit);
  }

  @override
  String get name => "LIMIT";
}
