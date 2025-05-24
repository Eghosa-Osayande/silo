import 'package:flutter/widgets.dart';
import 'package:silo_example_app/database.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDB();

  runApp(const MyApp());
}
