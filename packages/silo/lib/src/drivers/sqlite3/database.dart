import 'config.dart';
import 'conn.dart';
import 'dialector.dart';
import '../interfaces/config.dart';
import '../interfaces/database.dart';
import 'package:sqlite3/sqlite3.dart';

class Sqlite3DB extends DB with SqliteDialector, Sqlite3Connection {
  @override
  final Database db;

  @override
  final Config config = Sqlite3Config();

  Sqlite3DB._(this.db);

  static Future<Sqlite3DB> create(String path) async {
    final db = sqlite3.open(path);
    return Sqlite3DB._(db);
  }
}
