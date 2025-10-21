import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final DatabaseService databaseService;

  AuthBloc({required this.apiService, required this.databaseService}) : super(AuthInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  void _onLoadUser(LoadUserEvent event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        final userMap = json.decode(userJson);
        final user = UserModel.fromJson(userMap);
        
        // Set current user in database
        await databaseService.setCurrentUser(user.id);
        
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('Error loading user: $e');
      emit(AuthUnauthenticated());
    }
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiService.login(event.email, event.password);
      
      if (response.success) {
        final user = response.data!;
        
        // Set current user in database
        await databaseService.setCurrentUser(user.id);
        
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Login failed: $e'));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiService.register(
        event.name,
        event.email,
        event.password,
        event.dateOfBirth,
      );
      
      if (response.success) {
        emit(AuthRegistered());
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Registration failed: $e'));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('userId');
      
      // Clear all user data from local database
      await databaseService.clearAllUserData();
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: $e'));
    }
  }
}