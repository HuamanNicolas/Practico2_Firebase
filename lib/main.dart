import 'package:flutter/material.dart';
import 'package:practico2_firebase/src/pages/shopping_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 86, 9, 105)),
      ),
      debugShowCheckedModeBanner: false,
      home: const Shopping(title: 'Shopping'),
    );
  }
}

