# Silo ORM

**Silo** is an ORM-like Dart library that bridges the flexibility of raw SQL with the developer-friendly interface of key-value and document-style databases. Built on top of `async_sqlite` and `sqlite`, it provides a clean and extensible API via `silo_common`, allowing for future integrations with other SQL backends like `sqflite`.

---

## 🚀 Installation

Add Silo to your Dart or Flutter project:

```sh
dart pub add silo
```

Silo includes `sqlite3_flutter_libs` to bundle the native SQLite library for compatibility across platforms.

<!-- ---

## ✨ Features

* Simple key-value and typed object storage
* Query support via SQL-like expressions
* Auto-migration: Automatically creates or alters tables based on model structure
* Support for nested objects via dot-path access (e.g. `school.name`) -->

---

## 🔧 Setup & Integration

### 1. Define Your Models

Use `json_serializable` and mix in `SiloTable` to define your entities:

```dart
@JsonSerializable()
class Student with SiloTable<Student> {
  final String id;
  final String firstName, lastName;
  final String? middleName;
  final DateTime? dateOfBirth;
  final int? age;
  final School? school;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.age,
    this.school,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  @override
  String tableKey() => "id";

  @override
  Map<String, dynamic> toMap() => toJson();
}
```

You can also define custom scalar value types using `SiloValue`:

```dart
class Url with SiloValue {
  final Uri uri;

  Url(this.uri);

  factory Url.parse(String v) => Url(Uri.parse(v));

  @override
  String toJson() => uri.toString();
}
```

### 2. Initialize the Database

```dart
final db = await SiloDB.fromPath("z.db");
```

### 3. Register Factories

Register named and custom type factories:

```dart
SiloRegistry.registerNamedFactory("students", Student.fromJson);
SiloRegistry.registerFactory(Url.parse);
```

### 4. Auto-Migration

Generate or update tables automatically:

```dart
await db.migrator.autoMigrateSiloTable(person);
```

This adds any missing columns if the table already exists.

### 5. Key-Value Usage

```dart
await db.silo<int>().put("akey", 1234);
final val = await db.silo<int>().get("akey");
print(val); // 1234
```

### 6. Storing and Querying Objects

```dart
final silo = db.silo<Student>();
await silo.putSilo(person);

final results = await silo
  .eq("firstName", "Ada")
  .find()
  .values;

print(results.map((e) => e.toJson()));
```

#### Querying Nested Fields

```dart
final nestedResults = await silo
  .like("school.name", "Par%")
  .find()
  .values;
```

---

## 🧹 Cleanup

```dart
await db.close();
```

---

<!-- ## 🧪 Example

For complete examples, check the `/example` directory or start with the `main()` function in the code above.

--- -->

## 🔗 License

MIT

---
