import 'package:integration_test/integration_test.dart';
import 'package:silo_sqlite3/silo_sqlite3.dart' as sqlite3;

import 'common.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await commonTest("sqlite3", () async {
    var sqlite3Conn = sqlite3.sqlite3.openInMemory();
    return sqlite3.DBSqlite3(sqlite3Conn);
  });
}
