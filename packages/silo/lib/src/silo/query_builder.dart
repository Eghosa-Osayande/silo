import 'package:silo/src/silo/registry.dart';
import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/clauses/from.dart';
import 'package:silo/src/sql/clauses/limit.dart';
import 'package:silo/src/sql/clauses/offset.dart';
import 'package:silo/src/sql/clauses/select.dart';
import 'package:silo/src/sql/clauses/where.dart';
import 'package:silo/src/sql/expression/condition.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/sql/expression/quoted.dart';
import 'package:silo/src/sql/statement.dart';
import 'models.dart';
import 'silo.dart';

enum Logic {
  and("AND"),
  or("OR");

  final String name;
  const Logic(this.name);
}

mixin SiloQueryBuilder<T extends Silo<O>, O> {
  T get _silo => this as T;
  final Map<String, Expression> _selection = {};

  final List<Expression> _conditions = [];
  final List<Expression> _joins = [];

  int? _limit;
  int? _offset;

  String? _tableName;

  bool get hasConditions => _conditions.isNotEmpty;

  T select(List<String> selections) {
    _selection.clear();
    for (var selection in selections) {
      _selection[selection] = Quoted(selection);
    }
    return this as T;
  }

  T from(String table) {
    _tableName = table;
    return this as T;
  }

  String get tableName {
    if (_tableName != null) return _tableName!;
    final factoryName = SiloRegistry.factoryNameOrNull<O>();

    if (factoryName != null) return factoryName;

    if (<O>[] is List<SiloTable<O>>) {
      throw Exception("no registered named factory found for SiloTable $T");
    }

    return _silo.db.migrator.typeToTableName(O);
  }

  Expression get tableExpr {
    return Quoted(tableName);
  }

  T limit(int limit) {
    _limit = limit;
    return this as T;
  }

  T offset(int offset) {
    _offset = offset;
    return this as T;
  }

  T eq(
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    dynamic value, {
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
    String column,
    Iterable values, {
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
    String column,
    Iterable values, {
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

  Expression _transformDataColumn(String dataColumn) {
    // if (<O>[] is List<SiloTable>) {
    //   return Expr(dataColumn);
    // }
    String output = _transformColumns(dataColumn);
    return Expr(output);
  }

  String _transformColumns(String query) {
    final sep = ".";

    if (query.isEmpty) {
      query = sep;
    }

    final index = query.indexOf(sep);
    if (index == -1) {
      return query;
    }

    var col = query.substring(0, index);
    var filter = query.substring(index);

    if (col.isEmpty) {
      col = "value";
    }

    if (filter == sep) {
      filter = "";
    }

    col = _silo.db.dialector.quote(col);

    return "json_extract($col, '\$$filter')";
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
