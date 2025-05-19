import 'package:integration_test/integration_test.dart';
import 'package:silo_sqflite/silo_sqflite.dart' as sqflite;

import 'common.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await commonTest("sqflite", () async {
    final sqfliteConn = await sqflite.openDatabase('sqlflite_db.db');
    return sqflite.DBSqflite(sqfliteConn);
  });
}
