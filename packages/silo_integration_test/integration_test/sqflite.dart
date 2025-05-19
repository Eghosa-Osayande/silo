import 'package:integration_test/integration_test.dart';
import 'package:silo_sqflite/silo_sqflite.dart';

import 'common.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await commonTest("sqflite", () async {
    final sqfliteConn = await openDatabase('sqlflite_db.db');
    return DBSqflite(sqfliteConn);
  });
}
