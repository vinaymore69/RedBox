import 'package:flutter/material.dart';

// import 'package:redbox/pages/home.dart';
import 'package:redbox/pages/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main page',

    debugShowCheckedModeBanner: false,
    home:  const LoginPage(),
    );
  }
}



