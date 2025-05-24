import 'package:flutter/material.dart';
import 'package:silo/silo.dart';
import 'package:silo_example_app/database.dart';
import 'package:silo_example_app/models/student.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Silo App',
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await db.silo().put("key", 9999);
              final person2 = Student(
                id: "student2",
                firstName: "John",
                lastName: "Ago",
                dateOfBirth: DateTime(2000, 1, 1),
                age: 25,
                school: School(id: "school2", name: "Hawk"),
              );

              await Silo<Student>(db).putSilo(person2);
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              final v =
                  await db
                      .silo<Student>()
                      .eq("school.name", "Hawk")
                      .find()
                      .values;
              print(v);
              print(await db.silo().get("key"));
            },
          ),
        ],
      ),
    );
  }
}
