import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/drivers/interfaces/database.dart';

abstract class Condition implements Expression {
  final bool? isFirst;
  final bool? negate;

  Condition({
    this.isFirst,
    this.negate,
  });
}

class GroupCondition extends Condition {
  final String logicalOperator;
  final List<Expression> conditions;
  final bool withParenthesis;

  GroupCondition({
    required this.logicalOperator,
    required this.conditions,
    this.withParenthesis = true,
    super.isFirst,
    super.negate,
  });

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);

    if (negate == true) {
      builder.writeString("NOT ");
    }

    if (isFirst != true) {
      builder.writeString("$logicalOperator ");
    }

    if (withParenthesis) {
      builder.writeString("(");
    }

    for (var c in conditions) {
      builder
        ..merge(c.build(db))
        ..writeString(" ");
    }

    builder.trimRight();

    if (withParenthesis) {
      builder.writeString(")");
    }

    return builder;
  }
}

abstract class SingleCondition extends Condition {
  final String logicalOp;
  final Expression column;
  final String op;
  final dynamic value;

  SingleCondition({
    required this.logicalOp,
    required this.column,
    required this.op,
    required this.value,
    super.isFirst,
    super.negate,
  });
}

class Eq extends SingleCondition {
  Eq({
    required super.logicalOp,
    required super.column,
    required super.op,
    required super.value,
    super.isFirst,
    super.negate,
  });

  @override
  ExprBuilder build(DB db) {
    final builder = ExprBuilder(db);

    if (isFirst != true) {
      builder.writeString("$logicalOp ");
    }

    if (negate == true) {
      builder.writeString("NOT (");
    }

    builder
      ..merge(column.build(db))
      ..writeString(" $op ");

    switch (value) {
      case Expression value:
        builder.merge(value.build(db));
        break;
      default:
        builder
          ..writeString(" ")
          ..addVar(value);
    }

    if (negate == true) {
      builder.writeString(")");
    }

    return builder;
  }
}
