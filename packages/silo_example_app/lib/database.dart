import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silo/silo.dart';
import 'package:silo_example_app/models/student.dart';

DB? _db;

DB get db => _db!;

Future<void> initDB() async {
  String path = "z.db";

  if (!kIsWeb) {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    path = "${appDocumentsDir.path}/$path";
  }

  _db ??= await SiloDB.fromPath(path);
  SiloRegistry.registerNamedFactory("students", Student.fromJson);
}
