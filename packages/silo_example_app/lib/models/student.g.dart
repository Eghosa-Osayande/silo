// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      age: (json['age'] as num?)?.toInt(),
      school: json['school'] == null
          ? null
          : School.fromJson(json['school'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'id': instance.id,
      'middleName': instance.middleName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'age': instance.age,
      'school': instance.school,
    };

School _$SchoolFromJson(Map<String, dynamic> json) => School(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };
