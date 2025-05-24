import 'dart:io';

import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silo/silo.dart';

import 'common.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await commonTest("sqlite3", () async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    return openDB("${appDocumentsDir.path}/path.db");
  });
}
