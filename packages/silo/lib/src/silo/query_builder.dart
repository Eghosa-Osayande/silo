import '../sql/clauses/clause.dart';
import '../sql/clauses/from.dart';
import '../sql/clauses/limit.dart';
import '../sql/clauses/offset.dart';
import '../sql/clauses/select.dart';
import '../sql/clauses/where.dart';
import '../sql/expression/condition.dart';
import '../sql/expression/expression.dart';
import '../sql/expression/quoted.dart';
import '../sql/statement.dart';

import 'silo.dart';

enum Logic {
  and("AND"),
  or("OR");

  final String name;
  const Logic(this.name);
}

mixin SiloQueryBuilder<T extends Silo> {
  T get _silo => this as T;
  final Map<String, Expression> _selection = {};

  final List<Expression> _conditions = [];
  final List<Expression> _joins = [];

  int? _limit;
  int? _offset;

  bool get hasConditions => _conditions.isNotEmpty;

  T select(List<String> selections) {
    _selection.clear();
    for (var selection in selections) {
      _selection[selection] = Quoted(selection);
    }
    return this as T;
  }

  T limit(int limit) {
    _limit = limit;
    return this as T;
  }

  T offset(int offset) {
    _offset = offset;
    return this as T;
  }

  Expression _transformDataColumn(String dataColumn) {
    String output = _transformColumns(dataColumn);
    return Expr(output);
  }

  T eq(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "=",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T neq(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "<>",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T gt(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: ">",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T gte(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: ">=",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T lt(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "<",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T lte(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "<=",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T like(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "like",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T ilike(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "ilike",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T IS(
    dynamic value, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: _transformDataColumn(column),
      op: "IS",
      value: value,
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T expired({
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("expired_at"),
      op: "<=",
      value: DateTime.now().toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T notExpired({
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("expired_at"),
      op: ">",
      value: DateTime.now().toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T createdAfter(
    DateTime date, {
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("created_at"),
      op: ">",
      value: date.toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T createdBefore(
    DateTime date, {
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("created_at"),
      op: "<",
      value: date.toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T updatedAfter(
    DateTime date, {
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("updated_at"),
      op: ">",
      value: date.toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T updatedBefore(
    DateTime date, {
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(Eq(
      logicalOp: logicOp.name,
      column: Quoted("updated_at"),
      op: "<",
      value: date.toUtc().toIso8601String(),
      isFirst: _conditions.isEmpty,
      negate: negate,
    ));
    return this as T;
  }

  T inList(
    Iterable values, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(
      Eq(
        logicalOp: logicOp.name,
        column: _transformDataColumn(column),
        op: "IN",
        value: values,
        isFirst: _conditions.isEmpty,
        negate: negate,
      ),
    );
    return this as T;
  }

  T notInList(
    Iterable values, {
    String column = "#",
    bool negate = false,
    Logic logicOp = Logic.and,
  }) {
    _conditions.add(
      Eq(
        logicalOp: logicOp.name,
        column: _transformDataColumn(column),
        op: "NOT IN",
        value: values,
        isFirst: _conditions.isEmpty,
        negate: negate,
      ),
    );
    return this as T;
  }

  T where(Silo silo) {
    return _where("AND", silo);
  }

  T or(Silo silo) {
    return _where("OR", silo);
  }

  T raw(String query, [List<dynamic>? args]) {
    String output = _transformColumns(query);

    _where("AND", output, args);

    return this as T;
  }

  String _transformColumns(String query) {
    final pattern = RegExp(
      r'\#(?:[a-zA-Z0-9_-]+(?:\[\d+\])?)*(?:\.[a-zA-Z0-9_-]+(?:\[\d+\])?)*',
    );

    final output = query.replaceAllMapped(
      pattern,
      (match) {
        final original = match.group(0)!;
        String ps;
        if (original == '#') {
          ps = r'$';
        } else {
          ps = r'$.';
        }
        return "json_extract(`value`, '${original.replaceFirst('#', ps)}')";
      },
    );
    return output;
  }

  T _where(String logicOp, dynamic query, [List<dynamic>? args]) {
    final isFirst = _conditions.isEmpty;
    switch (query) {
      case String query:
        _conditions.add(
          Expr(
            '${isFirst ? '' : '$logicOp '} $query',
            args ?? [],
          ),
        );
        break;

      case Silo query:
        _conditions.add(
          GroupCondition(
            logicalOperator: logicOp,
            conditions: query._conditions,
            withParenthesis: query._conditions.length > 1,
            isFirst: _conditions.isEmpty,
          ),
        );
        break;
      default:
    }
    return this as T;
  }

  Statement toStatement() {
    final clauses = <String, Clause>{};
    final stmt = Statement(clauses: clauses);

    var initialSelection = <Expression>[];

    if (_selection.isNotEmpty) {
      initialSelection = _selection.values.toList();
    } else {
      initialSelection = [Expr("*", [])];
    }

    final selectClause = Select(initialSelection, null);

    final fromClause = From(_silo.tableExpr, _joins);
    selectClause;

    stmt.addClauses([
      fromClause,
      selectClause,
    ]);

    if (_conditions.isNotEmpty) {
      final whereClause = Where(_conditions);
      clauses[whereClause.name] = whereClause;
    }

    if (_limit != null) {
      final limitClause = Limit(_limit!);
      clauses[limitClause.name] = limitClause;
    }

    if (_offset != null) {
      final offsetClause = Offset(_offset!);
      clauses[offsetClause.name] = offsetClause;
    }

    return Statement(clauses: clauses);
  }
}
