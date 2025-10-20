import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.8.155:3000/api';

  Future<http.Response> _request(String method, String endpoint, {dynamic body, String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: json.encode(body));
      case 'PUT':
        return await http.put(url, headers: headers, body: json.encode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Invalid HTTP method');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Auth methods
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    try {
      final response = await _request('POST', '/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final apiResponse = ApiResponse<UserModel>.fromJson(jsonResponse, (data) => UserModel.fromJson(data['user']));
        if (apiResponse.success) {
          // Save token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', jsonResponse['data']['token']);
          await prefs.setInt('userId', apiResponse.data!.id);
        }
        return apiResponse;
      } else {
        return ApiResponse(success: false, message: 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Login failed: $e');
    }
  }

  Future<ApiResponse<dynamic>> register(String name, String email, String password, String dateOfBirth) async {
    try {
      final response = await _request('POST', '/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
        'date_of_birth': dateOfBirth,
      });

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Registration failed: $e');
    }
  }

  // Transaction methods
  Future<ApiResponse<List<TransactionModel>>> getTransactions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('GET', '/transactions', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<List<TransactionModel>>.fromJson(
          jsonResponse,
          (data) => (data as List).map((item) => TransactionModel.fromJson(item)).toList(),
        );
      } else {
        return ApiResponse(success: false, message: 'Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to fetch transactions: $e');
    }
  }

  Future<ApiResponse<dynamic>> createTransaction(TransactionModel transaction) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('POST', '/transactions', body: transaction.toJson(), token: token);
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to create transaction: $e');
    }
  }

  Future<ApiResponse<dynamic>> updateTransaction(TransactionModel transaction) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('PUT', '/transactions/${transaction.serverId}', body: transaction.toJson(), token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to update transaction: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to update transaction: $e');
    }
  }

  Future<ApiResponse<dynamic>> deleteTransaction(int transactionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('DELETE', '/transactions/$transactionId', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to delete transaction: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to delete transaction: $e');
    }
  }

  // Goal methods
  Future<ApiResponse<List<GoalModel>>> getGoals() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('GET', '/goals', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<List<GoalModel>>.fromJson(
          jsonResponse,
          (data) => (data as List).map((item) => GoalModel.fromJson(item)).toList(),
        );
      } else {
        return ApiResponse(success: false, message: 'Failed to fetch goals: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to fetch goals: $e');
    }
  }

  Future<ApiResponse<dynamic>> createGoal(GoalModel goal) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('POST', '/goals', body: goal.toJson(), token: token);
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to create goal: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to create goal: $e');
    }
  }

  Future<ApiResponse<dynamic>> updateGoal(GoalModel goal) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('PUT', '/goals/${goal.serverId}', body: goal.toJson(), token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to update goal: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to update goal: $e');
    }
  }

  Future<ApiResponse<dynamic>> deleteGoal(int goalId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('DELETE', '/goals/$goalId', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to delete goal: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to delete goal: $e');
    }
  }

  // Report methods
  Future<ApiResponse<dynamic>> getMonthlyReport(int month, int year) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('GET', '/report?month=$month&year=$year', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to fetch report: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to fetch report: $e');
    }
  }

  Future<ApiResponse<dynamic>> getYearlyReport(int year) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Not authenticated');
      }

      final response = await _request('GET', '/report/yearly?year=$year', token: token);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ApiResponse<dynamic>.fromJson(jsonResponse, (data) => data);
      } else {
        return ApiResponse(success: false, message: 'Failed to fetch yearly report: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to fetch yearly report: $e');
    }
  }
}