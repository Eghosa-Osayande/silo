import 'package:flutter_test/flutter_test.dart';
import 'package:silo/silo.dart';

Future<void> truncateAllTables(DB db) async {
  final tables = await db.query('''
    SELECT name FROM sqlite_master 
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
  ''');

  for (final table in tables) {
    final name = table['name'] as String;
    await db.exec('DELETE FROM "$name";');
  }
}

Future<void> commonTest(String prefix, Future<DB> Function() getDB) async {
  late DB db;
  late Silo silo;

  setUpAll(() async {
    db = await getDB();
    silo = Silo(db);
  });

  tearDown(() async {
    await truncateAllTables(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test("put and get value", () async {
    await silo.put("key", 123);
    final value = await silo.get("key");
    expect(value, equals(123));
  });

  test("remove value", () async {
    await silo.put("key", 123);
    await silo.remove("key");
    final value = await silo.get("key");
    expect(value, isNull);
  });

  test("commit on successful transaction", () async {
    await silo.transaction((silo) async {
      await silo.put("key", 321);
    });

    final value = await silo.get("key");
    expect(value, equals(321));
  });

  test("rollback on transaction error", () async {
    var value = await silo.get("key");
    expect(value, isNull);
    try {
      await silo.transaction((silo) async {
        await silo.put("key", 321);
        throw Exception("rollback");
      });
    } catch (_) {}

    value = await silo.get("key");
    expect(value, isNull);
  });
}
