import 'package:silo/src/sql/expression/expression.dart';

abstract class Dialector {
  String quote(String str);
  writeVar(ExprBuilder builder);
}
