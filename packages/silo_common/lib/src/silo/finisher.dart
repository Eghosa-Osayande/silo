import 'dart:collection';

import '/src/drivers/interfaces/database.dart';
import '/src/silo/models.dart';
import '/src/silo/registry.dart';
import '/src/sql/clauses/clause.dart';
import '/src/sql/clauses/delete.dart';
import '/src/sql/clauses/from.dart';
import '/src/sql/clauses/insert.dart';
import '/src/sql/clauses/on_conflict.dart';
import '/src/sql/clauses/select.dart';
import '/src/sql/clauses/set.dart';
import '/src/sql/clauses/values.dart';
import '/src/sql/clauses/where.dart';
import '/src/sql/expression/expression.dart';
import '/src/sql/expression/quoted.dart';
import '/src/utils/utils.dart';

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

extension FutureSiloRowsX<T> on Future<SiloRows<T>> {
  Future<List<T>> get values => this.then(
        (value) => value.rows
            .map(
              (e) => e.value,
            )
            .toList(),
      );
}

mixin SiloFinisher<S extends Silo<O>, O> {
  S get _silo => this as S;

  DB get _db {
    return _silo.db;
  }

  static final _createdTables = <String, bool>{};

  Future<void> _createValueTable() async {
    final hasCreatedTable = _createdTables[_silo.tableName];

    if (hasCreatedTable == true) {
      return;
    }

    final hasTable = await _db.migrator.hasTable(_silo.tableName);

    if (!hasTable) {
      await _db.migrator.createValueTable(_silo.tableName);
    }

    _createdTables[_silo.tableName] = true;
  }

  Future<void> put(String key, O value, {DateTime? expireAt}) async {
    final obj = encodeObj(value);
    await _createValueTable();

    final statement = _silo.toStatement();

    final updateValues = <String, dynamic>{
      "value": obj,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
      "expired_at": expireAt?.toUtc().toIso8601String(),
    };

    final createValues = <String, dynamic>{
      "key": key,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      ...updateValues,
    };

    statement.addClauses(
      [
        Insert(_silo.tableExpr, orReplace: _db.dialector.supportsOrReplace()),
        Values(
          createValues.keys.map((e) => Quoted(e)),
          createValues.values,
        ),
        if (!_db.dialector.supportsOrReplace())
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
                      _silo.tableExpr,
                      Quoted(e),
                    ],
                  ),
                ),
              ],
              isExcluded: true,
              table: _silo.tableExpr,
            ),
          ),
      ],
    );

    var q = statement.buildClauses(_db, kCreateClauses);

    await _db.exec(q.sql, q.args);
  }

  Future<void> remove(String key) async {
    await _createValueTable();
    final statement = _silo.toStatement();

    statement.addClauses([
      From(_silo.tableExpr, []),
      Delete(),
      Where([
        Expr(
          '? = ?',
          [Quoted("key"), key],
        )
      ])
    ]);

    var q = statement.buildClauses(_db, kDeleteClauses);

    await _db.exec(q.sql, q.args);
  }

  Future<O?> get(String key) async {
    await _createValueTable();
    var statement = _silo.toStatement();

    statement.addClauses([
      Select([Expr("*")], []),
      From(_silo.tableExpr, []),
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

    final q = statement.buildClauses(_db, kQueryClauses);

    final results = await _db.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return rows.firstOrNull?.value;
  }

  Future<SiloRows<O>> find() async {
    await _createValueTable();
    var q = _silo.toStatement().buildClauses(_db, kQueryClauses);

    final results = await _db.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return SiloRows(rows);
  }

  Future<SiloRow<O>?> first() async {
    await _createValueTable();
    var q = _silo.limit(1).toStatement().buildClauses(_db, kQueryClauses);

    final results = await _db.query(q.sql, q.args);

    if (results.firstOrNull == null) {
      return null;
    }
    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    return rows.first;
  }

  Future<T> transaction<T>(T Function(Silo<O> tx) action) async {
    return _db.transaction(
      (tx) async {
        return action(Silo(tx));
      },
    );
  }

  SiloRow<O> _toSiloRow(Map<String, Object?> e) {
    if (<O>[] is List<SiloTable>) {
      final m = <String, dynamic>{};

      for (var key in e.keys) {
        m[key] = decodeObj(e[key].toString());
      }

      final fn = SiloRegistry.factoryFor<O>();
      final value = fn(m) as SiloTable;
      return SiloRow(value: value as O, key: e[value.tableKey()].toString());
    } else {
      e = Map.from(e);
      final obj = decodeObj(e["value"].toString());
      O value;

      try {
        final fn = SiloRegistry.factoryFor<O>();
        value = fn(obj);
      } catch (e) {
        value = obj as O;
      }

      e["value"] = value;
      return SiloRow(value: value, key: e["key"].toString());
    }
  }

  Future<void> putSilo(SiloTable<O> obj) async {
    if (<O>[] is! List<SiloTable>) {
      throw Exception(
        "$obj is not an instance of $SiloTable",
      );
    }

     await _db.migrator.autoMigrateSiloTable(obj);

    final table = obj as SiloTable;
    final createValues = table.toMap();

    for (final entry in createValues.entries) {
      createValues[entry.key] = encodeObj(entry.value);
    }

    final updateValues = Map.from(createValues)..remove(table.tableKey());

   

    final statement = _silo.toStatement();

    statement.addClauses(
      [
        Insert(_silo.tableExpr, orReplace: _db.dialector.supportsOrReplace()),
        Values(
          createValues.keys.map((e) => Quoted(e)),
          createValues.values,
        ),
        if (!_db.dialector.supportsOrReplace())
          OnConflict(
            [
              Quoted(table.tableKey()),
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
                      _silo.tableExpr,
                      Quoted(e),
                    ],
                  ),
                ),
              ],
              isExcluded: true,
              table: _silo.tableExpr,
            ),
          ),
      ],
    );

    var q = statement.buildClauses(_db, kCreateClauses);

    await _db.exec(q.sql, q.args);
  }
}
