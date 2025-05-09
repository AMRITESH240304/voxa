import 'package:flutter/material.dart';
import 'package:frontend/views/BubblePage.dart';


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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white70,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6E8AFA),
          secondary: Color(0xFF9C64FF),
        ),
      ),
      home: const BubblePage(),
    );
  }
}

