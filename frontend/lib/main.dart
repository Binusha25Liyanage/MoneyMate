import 'package:flutter/material.dart';
import 'package:money_mate/screens/page_selection.dart';
import 'package:money_mate/screens/auth_screens/signup_screen.dart';
import 'package:money_mate/screens/transaction_screen.dart';
import 'screens/auth_screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => PageSelection(),
        '/transactions': (context) => TransactionsScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}