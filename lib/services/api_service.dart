import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  // If testing on a physical phone over Wi-Fi, set your PC local IP here (e.g. 'http://192.168.1.5:8000/api')
  static String customUrl = '';

  // Base API URL configuration
  // ADB reverse tcp:8000 tcp:8000 bridges Android directly to PC localhost (127.0.0.1:8000)
  static String get baseUrl {
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// User Registration Endpoint Call
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("REGISTER URL: $baseUrl/register");
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      debugPrint(
        "REGISTER Status: ${response.statusCode}, Body: ${response.body}",
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      debugPrint("REGISTER Catch Error: $e");
      return AuthResponse(
        success: false,
        message:
            'Could not connect to backend server ($baseUrl). Check if server & MySQL are running. Error: $e',
      );
    }
  }

  /// User Login Endpoint Call
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("LOGIN URL: $baseUrl/login");
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint(
        "LOGIN Status: ${response.statusCode}, Body: ${response.body}",
      );

      if (response.statusCode >= 500) {
        return AuthResponse(
          success: false,
          message:
              'Server error (${response.statusCode}). Please verify XAMPP MySQL database is running.',
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      debugPrint("LOGIN Catch Error: $e");
      return AuthResponse(
        success: false,
        message:
            'Could not connect to backend server ($baseUrl). Check if PHP server is running. Error: $e',
      );
    }
  }

  /// Get Authenticated User Profile Endpoint Call
  static Future<AuthResponse> getProfile(String token) async {
    try {
      debugPrint("PROFILE URL: $baseUrl/me");
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      debugPrint(
        "PROFILE Status: ${response.statusCode}, Body: ${response.body}",
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      debugPrint("PROFILE Catch Error: $e");
      return AuthResponse(
        success: false,
        message: 'Could not connect to backend server ($baseUrl). Error: $e',
      );
    }
  }

  /// Fetch All Expenses / Incomes from MySQL Database
  static Future<List<Map<String, dynamic>>> fetchExpensesFromDb() async {
    try {
      debugPrint("FETCH EXPENSES URL: $baseUrl/expenses");
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: _headers,
      );

      debugPrint(
        "FETCH EXPENSES Status: ${response.statusCode}, Body: ${response.body}",
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint("FETCH EXPENSES Error: $e");
      return [];
    }
  }

  /// Save Expense / Income to MySQL Database
  static Future<Map<String, dynamic>?> saveExpenseToDb({
    required String name,
    required String description,
    required double amount,
    required String type,
  }) async {
    try {
      debugPrint("SAVE EXPENSE URL: $baseUrl/expenses");
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'amount': amount,
          'type': type,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      debugPrint(
        "SAVE EXPENSE Status: ${response.statusCode}, Body: ${response.body}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint("SAVE EXPENSE Error: $e");
      return null;
    }
  }

  /// Delete Expense / Income from MySQL Database
  static Future<bool> deleteExpenseFromDb(String id) async {
    try {
      debugPrint("DELETE EXPENSE URL: $baseUrl/expenses/delete");
      final response = await http.post(
        Uri.parse('$baseUrl/expenses/delete'),
        headers: _headers,
        body: jsonEncode({'id': id}),
      );

      debugPrint(
        "DELETE EXPENSE Status: ${response.statusCode}, Body: ${response.body}",
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("DELETE EXPENSE Error: $e");
      return false;
    }
  }
}
