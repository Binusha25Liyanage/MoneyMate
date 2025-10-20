import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
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
