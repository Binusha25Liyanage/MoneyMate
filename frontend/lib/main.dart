import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_mate/blocs/sync/sync_bloc.dart';
import 'package:money_mate/screens/auth_screens/login_screen.dart';
import 'package:money_mate/screens/auth_screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/goal/goal_bloc.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'screens/page_selection.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  final DatabaseService databaseService = DatabaseService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            apiService: apiService,
            databaseService: databaseService,
          )..add(LoadUserEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            apiService: apiService,
            databaseService: databaseService,
          ),
        ),
        BlocProvider<GoalBloc>(
          create: (context) => GoalBloc(
            apiService: apiService,
            databaseService: databaseService,
          ),
        ),
        BlocProvider<SyncBloc>(
          create: (context) => SyncBloc(
            apiService: ApiService(),
            databaseService: DatabaseService(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Mate',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => FutureBuilder<bool>(
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Color(0xFF0F0F23),
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return snapshot.data == true ? PageSelection() : LoginScreen();
            },
          ),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => PageSelection(),
        },
      ),
    );
  }

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');
    return token != null && userJson != null;
  }
}