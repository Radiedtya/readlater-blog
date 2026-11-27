import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constant.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  // ---------- token storage ----------
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

  // ---------- login ----------
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}${ApiConstant.login}');
    debugPrint('→ POST $uri');
    debugPrint('  body: {email: ${email.trim()}}');

    late final http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );
    } catch (e) {
      debugPrint('✗ Network error: $e');
      throw AuthException('Tidak dapat terhubung ke server.');
    }

    debugPrint('← status: ${res.statusCode}');
    debugPrint('← body: ${res.body}');

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Response server tidak valid.');
    }

    if (res.statusCode != 200) {
      throw AuthException(
        _extractMessage(body) ?? 'Login gagal (${res.statusCode})',
      );
    }

    final token = _extractToken(body);
    if (token == null) {
      throw AuthException(
        'Login berhasil tetapi token tidak ditemukan di response. '
        'Cek bentuk response di console.',
      );
    }
    await _saveToken(token);

    final userJson = _extractUserJson(body);
    if (userJson == null) {
      throw AuthException('Data user tidak ditemukan di response.');
    }

    debugPrint('✓ Token tersimpan (${token.length} char) & user parsed');
    return User.fromJson(userJson);
  }

  // ---------- register ----------
  static Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}${ApiConstant.register}');
    debugPrint('→ POST $uri');

    late final http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
    } catch (e) {
      debugPrint('✗ Network error: $e');
      throw AuthException('Tidak dapat terhubung ke server.');
    }

    debugPrint('← status: ${res.statusCode}');
    debugPrint('← body: ${res.body}');

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Response server tidak valid.');
    }

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw AuthException(
        _extractMessage(body) ?? 'Registrasi gagal (${res.statusCode})',
      );
    }

    final token = _extractToken(body);
    if (token == null) {
      throw AuthException('Registrasi berhasil tetapi token tidak ditemukan.');
    }
    await _saveToken(token);

    final userJson = _extractUserJson(body);
    if (userJson == null) {
      throw AuthException('Data user tidak ditemukan di response.');
    }
    return User.fromJson(userJson);
  }

  // ---------- me / logout ----------
  static Future<User?> me() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.me}'),
      headers: await authHeaders(),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final userJson = _extractUserJson(body);
      if (userJson != null) return User.fromJson(userJson);
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

  // ---------- extractors ----------
  static String? _extractToken(Map<String, dynamic> body) {
    if (body['token'] is String && (body['token'] as String).isNotEmpty) {
      return body['token'] as String;
    }
    if (body['access_token'] is String) {
      return body['access_token'] as String;
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      if (data['token'] is String && (data['token'] as String).isNotEmpty) {
        return data['token'] as String;
      }
      if (data['access_token'] is String) {
        return data['access_token'] as String;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractUserJson(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      // bentuk: { data: { id, name, email } }
      if (data['id'] != null) return data;
      // bentuk: { data: { user: { id, ... } } }
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic> && nestedUser['id'] != null) {
        return nestedUser;
      }
    }
    // bentuk: { user: { id, ... } }
    final user = body['user'];
    if (user is Map<String, dynamic> && user['id'] != null) {
      return user;
    }
    // bentuk: body langsung user
    if (body['id'] != null) return body;
    return null;
  }

  static String? _extractMessage(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstVal = errors[errors.keys.first];
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
    }
    return body['message'] as String?;
  }

  static Future<User> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}${ApiConstant.updateProfile}');
    debugPrint('→ PUT $uri');

    final payload = <String, dynamic>{
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (newPassword != null && newPassword.isNotEmpty) ...{
        'current_password': currentPassword ?? '',
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation ?? '',
      },
    };

    late final http.Response res;
    try {
      res = await http.put(
        uri,
        headers: await authHeaders(),
        body: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint('✗ Network error: $e');
      throw AuthException('Tidak dapat terhubung ke server.');
    }

    debugPrint('← status: ${res.statusCode}');
    debugPrint('← body: ${res.body}');

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Response server tidak valid.');
    }

    if (res.statusCode != 200) {
      throw AuthException(_extractMessage(body) ?? 'Gagal memperbarui profil.');
    }

    final userJson = _extractUserJson(body);
    if (userJson == null) {
      throw AuthException('Data user tidak ditemukan di response.');
    }
    return User.fromJson(userJson);
  }

  static Future<User> uploadProfileImage(Uint8List imageBytes) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Sesi login berakhir. Silakan masuk kembali.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              '${ApiConstant.baseUrl}${ApiConstant.uploadProfileImage}',
            ),
          )
          ..headers.addAll({
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          })
          ..files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              imageBytes,
              filename: 'profile.png',
            ),
          );

    late final http.Response response;
    try {
      response = await http.Response.fromStream(await request.send());
    } catch (error) {
      debugPrint('✗ Profile image upload failed: $error');
      throw AuthException('Tidak dapat mengunggah foto. Periksa koneksi.');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Response server tidak valid.');
    }

    if (response.statusCode != 200) {
      throw AuthException(
        _extractMessage(body) ??
            'Gagal mengunggah foto (${response.statusCode}).',
      );
    }

    final userJson = _extractUserJson(body);
    if (userJson == null) {
      throw AuthException('Data user tidak ditemukan di response.');
    }
    return User.fromJson(userJson);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
