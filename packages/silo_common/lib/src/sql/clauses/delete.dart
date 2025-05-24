import '../../drivers/interfaces/database.dart';
import 'clause.dart';
import '../expression/expression.dart';

class Delete with Clause {
  Delete();

  @override
  ExprBuilder build(DB db) {
    final b = ExprBuilder(db);
    return b;
  }

  @override
  String get name => "DELETE";
}
