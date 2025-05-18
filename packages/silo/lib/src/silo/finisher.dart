import '../sql/clauses/clause.dart';
import '../sql/clauses/delete.dart';
import '../sql/clauses/from.dart';
import '../sql/clauses/insert.dart';
import '../sql/clauses/on_conflict.dart';
import '../sql/clauses/select.dart';
import '../sql/clauses/set.dart';
import '../sql/clauses/values.dart';
import '../sql/clauses/where.dart';
import '../sql/expression/expression.dart';
import '../sql/expression/quoted.dart';
import '../utils/utils.dart';

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

extension ListSiloRowsX<T> on List<SiloRow<T>> {
  List<T> get values => this
      .map(
        (e) => e.value,
      )
      .toList();
}

extension FutureListSiloRowsX<T> on Future<List<SiloRow<T>>> {
  Future<List<T>> get values => this.then(
        (f) => f
            .map(
              (e) => e.value,
            )
            .toList(),
      );
}

extension FutureSiloRowsX<T> on Future<SiloRow<T>?> {
  Future<T?> get value => this.then(
        (f) => f?.value,
      );
}

mixin SiloFinisher<S extends Silo<O>, O> {
  S get _silo => this as S;

  static final _createdTables = <Type, bool>{};

  String get _tableName => _silo.db.typeToTableName(O);

  Expression get tableExpr => Quoted(_tableName);

  Future<void> _createTypeTable() async {
    final hasCreatedTable = _createdTables[O];

    if (hasCreatedTable == true) {
      return;
    }

    final tx = _silo.db;
    final hasTable=await tx.hasTable(_tableName);
    
    if (!hasTable) {
      await tx.createTypeTable<O>();
    }
    
    _createdTables[O] = true;
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
    final tx = _silo.db;

    var q = statement.buildClauses(tx, kCreateClauses);

    await tx.exec(q.sql, q.args);
    _silo.triggerAfterPut(key, value, q);
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
    final tx = _silo.db;
    var q = statement.buildClauses(tx, kDeleteClauses);

    await tx.exec(q.sql, q.args);
    _silo.triggerAfterRemove(key, q);
  }

  Future<O?> get(String key) async {
    await _createTypeTable();
    final db = _silo.db;
    var statement = Silo<O>().toStatement();

    statement.addClauses([
      Select([Expr("*")], []),
      From(tableExpr, []),
      Where([
        Expr(
          "? = ?",
          [Quoted("key"), key],
        ),
        Expr(
          "AND (`expired_at` IS NULL OR `expired_at` > ?)",
          [
            DateTime.now().toUtc().toIso8601String(),
          ],
        ),
      ])
    ]);

    final q = statement.buildClauses(db, kQueryClauses);

    final results = await _silo.db.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    _silo.triggerAfterFind(key, q, rows);
    return rows.firstOrNull?.value;
  }

  Future<List<SiloRow<O>>> find() async {
    await _createTypeTable();
    var q = _silo.toStatement().buildClauses(_silo.db, kQueryClauses);

    final results = await _silo.db.query(q.sql, q.args);

    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    _silo.triggerAfterFind(null, q, rows);

    return rows;
  }

  Future<SiloRow<O>?> first() async {
    await _createTypeTable();
    var q = _silo.limit(1).toStatement().buildClauses(_silo.db, kQueryClauses);

    final results = await _silo.db.query(q.sql, q.args);

    if (results.firstOrNull == null) {
      return null;
    }
    final rows = results.map((e) {
      return _toSiloRow(e);
    }).toList();

    _silo.triggerAfterFind(null, q, rows);

    return rows.first;
  }

  SiloRow<O> _toSiloRow(Map<String, Object?> e) {
    final obj = decodeObj(e["value"].toString());
    O value;

    try {
      final fn = _silo.siloFor<O>();
      value = fn(obj);
    } catch (e) {
      value = obj as O;
    }

    e["value"] = value;
    return SiloRow(value: value, key: e["key"].toString());
  }
}
