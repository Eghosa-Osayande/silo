import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silo/silo.dart';

import 'common.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await commonTest("sqlite3", () async {
    String path = "z.db";

    if (!kIsWeb) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      path = "${appDocumentsDir.path}/$path";
    }

    return SiloDB.fromPath(path);
  });
}
