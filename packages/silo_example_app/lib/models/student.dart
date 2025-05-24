import 'package:json_annotation/json_annotation.dart';
import 'package:silo/silo.dart';

part 'student.g.dart';

@JsonSerializable()
class Student with SiloTable<Student> {
  final String firstName, lastName, id;
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

@JsonSerializable()
class School with SiloValue{
  final String name, id;

  School({
    required this.id,
    required this.name,
  });

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
