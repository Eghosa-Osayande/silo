import 'package:flutter_test/flutter_test.dart';
import 'package:silo/silo.dart';
import 'package:silo_integration_test/student.dart';

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
  

  setUpAll(() async {
    db = await getDB();
  });

  tearDown(() async {
    await truncateAllTables(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test("put and get value", () async {
     final silo = Silo(db);
    await silo.put("key", 123);
    final value = await silo.get("key");
    expect(value, equals(123));
  });

  test("remove value", () async {
     final silo = Silo(db);
    await silo.put("key", 123);
    await silo.remove("key");
    final value = await silo.get("key");
    expect(value, isNull);
  });

  test("commit on successful transaction", () async {
     final silo = Silo(db);
    await silo.transaction((silo) async {
      await silo.put("key", 321);
    });

    final value = await silo.get("key");
    expect(value, equals(321));
  });

  test("rollback on transaction error", () async {
     final silo = Silo(db);
    var value = await silo.get("key");
    expect(value, isNull);
    try {
      await silo.transaction((tx) async {
        await tx.put("key", 321);
        throw Exception("rollback");
      });
    } catch (_) {}

    value = await silo.get("key");
    expect(value, isNull);
  });

  test("put silo table", () async {
    SiloRegistry.registerNamedFactory("students",Student.fromJson);

    final person = Student(
      id: "student1",
      firstName: "Ada",
      lastName: "Obi",
      dateOfBirth: DateTime(1995, 1, 1),
      age: 20,
      school: School(id: "school1", name: "Parrot"),
    );

    final person2 = Student(
      id: "student2",
      firstName: "John",
      lastName: "Ago",
      dateOfBirth: DateTime(2000, 1, 1),
      age: 25,
      school: School(id: "school2", name: "Hawk"),
    );

    var silo = Silo<Student>(db);
    await silo.putSilo(person);
    await silo.putSilo(person2);

    final r = await silo.like("school.name", "Ha%").find().values;

    expect(r.firstOrNull?.id, equals("student2"));
  });
}
