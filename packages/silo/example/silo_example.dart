import 'package:silo/silo.dart';

Future<void> main() async {
  // create db instance
  final db = await SiloDB.fromPath("z.db");

  await db.silo().put("first key", 1234);

  // type safe operation
  // saves to a different table
  await db.silo<int>().put("first key", 4321);

  // value1 and value2 are not equal
  // because they are saved to different tables
  // even though they have the same key
  final value1 = await db.silo<int>().get("first key"); // 4321

  final value2 = await db.silo().get("first key"); // 1234

  print(value1 == value2); // false

  await db.silo().remove("first key");

  // silo supports dart primitives
  // that are json serializable

  // register custom types that implement
  SiloRegistry.registerFactory(Url.parse);

  // put with expiration tiome
  await db.silo<Url>().put("a url", Url(Uri(path: "/a/url")),
      expireAt: DateTime.now().add(Duration(hours: 2)));

  // register SiloTable names and factories
  SiloRegistry.registerNamedFactory("students", Student.fromJson);

  // dummy student model for auto migration
  final dummyStudent = Student(
    id: "",
    firstName: "",
    lastName: "",
    age: 0,
    school: School(id: "", name: ""),
    profile: Url(Uri()),
  );

  // auto migrate student SiloTable
  // (different from SiloValue)
  await db.migrator.autoMigrateSiloTable(dummyStudent);

  await db.silo<Student>().putSilo(
        Student(
          id: "id",
          firstName: "Johnson",
          lastName: "James",
          age: 30,
          school: School(id: "schoolID", name: "Loohcs"),
          profile: Url(Uri()),
        ),
      );

  final results = await db
      .silo<Student>()
      .eq('id', 'id')
      .inList('lastName', ['James'])
      .like('firstName', 'John%')
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
  print(results);

  // close
  await db.close();
}

class Student with SiloTable<Student> {
  final String firstName, lastName, id;
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
        age: json['age'] as int,
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        profile: Url.parse(json['profile'] as String),
        school: json['school'] != null
            ? School.fromJson(json['school'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'profile': profile.toJson(),
        'school': school?.toJson(),
        'age': age,
      };

  @override
  String tableKey() => "id";

  @override
  Map<String, dynamic> toMap() => toJson();
}

class School with SiloValue {
  final String name, id;

  School({
    required this.id,
    required this.name,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Url with SiloValue {
  final Uri uri;

  Url(this.uri);

  factory Url.parse(String v) => Url(Uri.parse(v));

  @override
  String toJson() => uri.toString();
}
