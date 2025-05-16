import 'package:flutter/material.dart';
import 'package:frontend/views/bubble_page/bubble_page.dart';
import 'package:frontend/views/success_page/success_page.dart';
import 'package:frontend/views/verify_page/verify_page.dart';
import 'package:frontend/views/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOXA',
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
      home: const SuccessPage(userId: 'db337d06-acd3-4c10-9ae1-042d6dc9ea98', did: 'did:cheqd:testnet:4e76b9a5-9204-4786-8271-871084a6c51a'),
    );
  }
}

