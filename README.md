# Silo

**Silo** is an ORM-like library for Dart that blends key-value convenience with SQL-backed querying. Built on `async_sqlite` and `sqlite`, it provides a clean, extensible API through `silo_common`, with future support for more backends like `sqflite`.

---

## Installation
Add to pubspec.yaml. For flutter applications, add `sqlite3_flutter_libs` to include the native SQLite library.

```sh

dependencies:
  silo: ^1.0.2
  sqlite3_flutter_libs: ^0.5.30 # For flutter applications

```

## 1. Open the Database

Start by opening or creating your database:

```dart
final db = await SiloDB.fromPath("z.db");
```

## 2. Key-Value Storage

Use `silo<T>()` for type-safe storage:

```dart
  // type safe operation
  // saves to a different table
  await db.silo<int>().put("first key", 4321);

  // value1 and value2 are not equal
  // because they are saved to different tables
  // even though they have the same key
  final value1 = await db.silo<int>().get("first key"); // 4321

  final value2 = await db.silo().get("first key"); // 1234

  print(value1 == value2); // false
```

You can also set expiration for entries:

```dart
await db.silo<Url>().put(
  "a url",
  Url(Uri(path: "/a/url")),
  expireAt: DateTime.now().add(Duration(hours: 2)),
);
```

## 3. Custom Types & Factory Registration

To store custom types like `Uri`, implement `SiloValue`:

```dart
class Url with SiloValue {
  final Uri uri;

  Url(this.uri);
  factory Url.parse(String v) => Url(Uri.parse(v));

  @override
  String toJson() => uri.toString();
}
```

Register them globally before use:

```dart
SiloRegistry.registerFactory(Url.parse);
```

## 4. Silo Tables & Migration

Define structured models with `SiloTable<T>`:

```dart
class Student with SiloTable<Student> {
  final String id, firstName, lastName;
  final Url profile;
  final int age;
  final School? school;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profile,
    required this.age,
    this.school,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        profile: Url.parse(json['profile']),
        age: json['age'],
        school: json['school'] != null
            ? School.fromJson(json['school'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'profile': profile.toJson(),
        'age': age,
        'school': school?.toJson(),
      };

  @override
  String tableKey() => "id";

  @override
  Map<String, dynamic> toMap() => toJson();
}
```

Create or update tables automatically:

```dart
await db.migrator.autoMigrateSiloTable(Student(
  id: "",
  firstName: "",
  lastName: "",
  profile: Url(Uri()),
  age: 0,
  school: School(id: "", name: ""),
));
```

Register factory with table name:

```dart
SiloRegistry.registerNamedFactory("students", Student.fromJson);
```

## 5. Insert & Query Structured Data

Insert model instances:

```dart
await db.silo<Student>().putSilo(student);
```

Perform queries:

```dart
final results = await db
    .silo<Student>()
    .eq('firstName', 'John')
    .gte('age', 18)
    .find()
    .values;

print(results.map((e) => e.toJson()));
```

Supports nested queries and logical chaining:

```dart
final students = await db
    .silo<Student>()
    .eq('id', 'id')
    .inList('lastName', ['James'])
    .where(
      db.silo<Student>()
        ..gte('age', 20)
        ..or(
          db.silo<Student>()..lt('age', 70),
        ),
    )
    .eq('school.id', 'schoolID')
    .find()
    .values;
```

## Cleanup

Always close the database when done:

```dart
await db.close();
```

## License

MIT

