import '../../drivers/interfaces/database.dart';
import '../../utils/utils.dart';

typedef ExprBuild = (String sql, List vars);

class ExprBuilder {
  final _buffer = StringBuffer();
  final _var = [];
  final DB db;
  ExprBuild? _finalBuild;

  ExprBuilder(this.db);

  int get varLength => _var.length;

  ExprBuilder writeString(String str) {
    _buffer.write(str);
    _dispose();
    return this;
  }

  ExprBuilder writeQuoted(String str) {
    _buffer.write(db.quote(str));
    _dispose();
    return this;
  }

  ExprBuilder addVar(dynamic object) {
    _var.add(object);
    _buffer.write('?');
    _dispose();
    return this;
  }

  ExprBuilder _addVarWithDialector(dynamic object) {
    switch (object) {
      case Expression exp:
        final b = exp.build(db);
        writeString(b.sql);
        _var.addAll(b.args);
        break;
      default:
        _var.add(object);
        db.writeVar(this);
    }

    return this;
  }

  ExprBuilder merge(ExprBuilder other) {
    _buffer.write(other._buffer.toString());
    _var.addAll(other._var);
    _dispose();
    return this;
  }

  ExprBuilder append(String str, List vars) {
    _buffer.write(str);
    _var.addAll(vars);
    _dispose();
    return this;
  }

  ExprBuilder trimSuffix(String str) {
    final oldStr = _buffer.toString();
    _buffer
      ..clear()
      ..write(oldStr.trimSuffix(str));
    _dispose();
    return this;
  }

  ExprBuilder trimTrailingComma() {
    return this
      ..trimRight()
      ..trimSuffix(",");
  }

  ExprBuilder trimRight() {
    final oldStr = _buffer.toString();
    _buffer
      ..clear()
      ..write(oldStr.trimRight());
    _dispose();
    return this;
  }

  ExprBuild get finalBuild {
    if (_finalBuild != null) {
      return _finalBuild!;
    }

    var afterParenthesis = false;
    var idx = 0;
    final b = ExprBuilder(db);

    final rawSql = _buffer.toString();

    for (var v in rawSql.split("")) {
      if (v == '?' && _var.length > idx) {
        final rv = _var[idx];
        
        if (afterParenthesis) {
          switch (rv) {
            case Iterable rv:
              for (var (i, irv) in rv.indexed) {
                if (i > 0) {
                  b.writeString(",");
                }
                b._addVarWithDialector(irv);
              }
              break;
            default:
              b._addVarWithDialector(rv);
          }
        } else {
          b._addVarWithDialector(rv);
        }
        idx++;
      } else {
        afterParenthesis = v == '(';
        b.writeString(v);
      }
    }

    _finalBuild = (b._buffer.toString(), b._var);
    return _finalBuild!;
  }

  _dispose() {
    _finalBuild = null;
  }

  String get sql => finalBuild.$1;

  List get args => finalBuild.$2;

  Expression toExpression() {
    return Expr(_buffer.toString(), _var);
  }

  Future<void> exec() async {
    return db.exec(sql, args);
  }

  Future<List<Map<String, Object?>>> query() async {
    var r = await db.query(sql, args);
    return r;
  }

  Future<Map<String, Object?>?> first() async {
    var r = await query();
    return r.firstOrNull;
  }
}

abstract class Expression {
  ExprBuilder build(DB db);
}

class Expr implements Expression {
  final String sql;
  final List<dynamic> vars;

  Expr(this.sql, [this.vars = const []]);

  @override
  ExprBuilder build(DB db) {
    return ExprBuilder(db).append(sql, vars);
  }
}
