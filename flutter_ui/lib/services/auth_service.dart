import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constant.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.login}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && body['token'] != null) {
      await _saveToken(body['token'] as String);
      return User.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw AuthException(
      _extractMessage(body) ?? 'Login gagal (${res.statusCode})',
    );
  }

  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.register}'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201 && body['token'] != null) {
      await _saveToken(body['token'] as String);
      return User.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw AuthException(
      _extractMessage(body) ?? 'Registrasi gagal (${res.statusCode})',
    );
  }

  static Future<User?> me() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.me}'),
      headers: await authHeaders(),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return User.fromJson(body['data'] as Map<String, dynamic>);
    }
    return null;
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiConstant.baseUrl}${ApiConstant.logout}'),
        headers: await authHeaders(),
      );
    } catch (_) {
      // abaikan error jaringan saat logout
    }
    await clearToken();
  }

  static String? _extractMessage(Map<String, dynamic> body) {
    // Laravel validation: { message, errors: { field: [msg, ...] } }
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstVal = errors[errors.keys.first];
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
    }
    return body['message'] as String?;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}