import 'dart:collection';

import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/silo/registry.dart';
import 'package:silo/src/sql/clauses/clause.dart';
import 'package:silo/src/sql/clauses/delete.dart';
import 'package:silo/src/sql/clauses/from.dart';
import 'package:silo/src/sql/clauses/insert.dart';
import 'package:silo/src/sql/clauses/on_conflict.dart';
import 'package:silo/src/sql/clauses/select.dart';
import 'package:silo/src/sql/clauses/set.dart';
import 'package:silo/src/sql/clauses/values.dart';
import 'package:silo/src/sql/clauses/where.dart';
import 'package:silo/src/sql/expression/expression.dart';
import 'package:silo/src/sql/expression/quoted.dart';
import 'package:silo/src/utils/utils.dart';

import 'silo.dart';

class SiloRow<T> {
  final String key;
  final T value;

  const SiloRow({
    required this.key,
    required this.value,
  });

  @override
  String toString() => 'SiloRow(key: $key, value: $value)';
}

class SiloRows<T> with ListMixin<SiloRow<T>> {
  final List<SiloRow<T>> rows;
  SiloRows(this.rows);
  @override
  int get length => rows.length;

  @override
  set length(int newLength) {
    rows.length = newLength;
  }

  @override
  SiloRow<T> operator [](int index) {
    return rows[index];
  }

  @override
  void operator []=(int index, SiloRow<T> value) {
    rows[index] = value;
  }

  List<T> get values => rows
      .map(
        (e) => e.value,
      )
      .toList();
}

mixin SiloFinisher<S extends Silo<O>, O> {
  S get _silo => this as S;

  DB get _tx {
    return _silo.db;
  }

  static final _createdTables = <String, bool>{};

  String get _tableName => _silo.name ?? _tx.migrator.typeToTableName(O);

  Expression get tableExpr => Quoted(_tableName);

  Future<void> _createTypeTable() async {
    final hasCreatedTable = _createdTables[_tableName];

    if (hasCreatedTable == true) {
      return;
    }

    final tx = _tx;
    final hasTable = await tx.migrator.hasTable(_tableName);

    if (!hasTable) {
      await tx.migrator.createJsonTable(_tableName);
    }

    _createdTables[_tableName] = true;
  }

  Future<void> put(String key, O value, {DateTime? expireAt}) async {
    final obj = encodeObj(value);
    await _createTypeTable();

    final statement = _silo.toStatement();

    final updateValues = <String, dynamic>{
      "key": key,
      "value": obj,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
      "expired_at": expireAt?.toUtc().toIso8601String(),
    };

    statement.addClauses(
      [
        Insert(tableExpr),
        Values(
          [
            Quoted("created_at"),
            ...updateValues.keys.map(
              (e) => Quoted(e),
            )
          ],
          [
            DateTime.now().toUtc().toIso8601String(),
            ...updateValues.values,
          ],
        ),
        OnConflict(
          [
            Quoted("key"),
          ],
          doUpdate: SetClause(
            [
              ...updateValues.keys.map(
                (e) => Expr(
                  "? = COALESCE(?.?, ?.?)",
                  [
                    Quoted(e),
                    Quoted("excluded"),
                    Quoted(e),
                    tableExpr,
                    Quoted(e),
                  ],
                ),
              ),
            ],
            isExcluded: true,
            table: tableExpr,
          ),
        ),
      ],
    );
    final tx = _tx;

    var q = statement.buildClauses(tx, kCreateClauses);

    await tx.exec(q.sql, q.args);
  }

  Future<void> remove(String key) async {
    await _createTypeTable();
    final statement = _silo.toStatement();

    statement.addClauses([
      From(tableExpr, []),
      Delete(),
      Where([
        Expr(
          '? = ?',
          [Quoted("key"), key],
        )
      ])
    ]);
    final tx = _tx;
    var q = statement.buildClauses(tx, kDeleteClauses);

    await tx.exec(q.sql, q.args);
  }

  Future<O?> get(String key) async {
    await _createTypeTable();
    final db = _tx;
    var statement = _silo.toStatement();

    statement.addClauses([
      Select([Expr("*")], []),
      From(tableExpr, []),
      Where([
        Expr(
          "? = ?",
          [Quoted("key"), key],
        ),
        Expr(
          "AND (? IS NULL OR ? > ?)",
          [
            Quoted('expired_at'),
            Quoted('expired_at'),
            DateTime.now().toUtc().toIso8601String(),
          ],
        ),
      ])
    ]);

    final q = statement.buildClauses(db, kQueryClauses);

    final results = await _tx.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return rows.firstOrNull?.value;
  }

  Future<SiloRows<O>> find() async {
    await _createTypeTable();
    var q = _silo.toStatement().buildClauses(_tx, kQueryClauses);

    final results = await _tx.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return SiloRows(rows);
  }

  Future<SiloRow<O>?> first() async {
    await _createTypeTable();
    var q = _silo.limit(1).toStatement().buildClauses(_tx, kQueryClauses);

    final results = await _tx.query(q.sql, q.args);

    if (results.firstOrNull == null) {
      return null;
    }
    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return rows.first;
  }

  SiloRow<O> _toSiloRow(Map<String, Object?> e) {
    final obj = decodeObj(e["value"].toString());
    O value;

    try {
      final fn = SiloFactory.factoryFor<O>();
      value = fn(obj);
    } catch (e) {
      value = obj as O;
    }

    e["value"] = value;
    return SiloRow(value: value, key: e["key"].toString());
  }
}
