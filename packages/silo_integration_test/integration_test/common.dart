import 'package:flutter_test/flutter_test.dart';
import 'package:silo/silo.dart';

Future<void> commonTest(String prefix, Future<DB> Function() getDB) async {
  late DB db;

  setUp(() async {
    db = await getDB();
  });

  tearDown(() async {
    await db.close();
  });

  test("$prefix description", () async {
    final silo = Silo(db);

    await silo.put("key", 123);
    var value = await silo.get("key");
    expect(value, equals(123));

    silo.remove("key");
    value = await silo.get("key");
    expect(value, equals(null));
  });
}
