import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:message/screens/auth/login.dart';
import 'package:message/screens/auth/register.dart';
import 'package:message/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: _auth.currentUser != null ? 'home' : 'login',
      routes: {
        'login': (context) => login(),
        'register': (context) => register(),
        'home': (context) => home(),
      },
    );
  }
}
