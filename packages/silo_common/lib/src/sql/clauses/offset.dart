import 'clause.dart';
import '../expression/expression.dart';
import '../../drivers/interfaces/database.dart';

class Offset with Clause {
  final int offset;

  Offset(this.offset);

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db)
      ..writeString(" ")
      ..addVar(offset);
  }

  @override
  String get name => "OFFSET";
}
