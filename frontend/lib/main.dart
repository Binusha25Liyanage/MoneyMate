import 'package:flutter/material.dart';
import 'package:money_mate/screens/page_selection.dart';
import 'package:money_mate/screens/signup_screen.dart';
import 'package:money_mate/screens/transaction_screen.dart';
import 'screens/landing_screen/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/reports_screen.dart';
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
        '/': (context) => LandingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => PageSelection(),
        '/add': (context) => AddTransactionScreen(),
        '/transactions': (context) => TransactionsScreen(),
        '/budgets': (context) => BudgetsScreen(),
        '/savings': (context) => SavingsScreen(),
        '/reports': (context) => ReportsScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}