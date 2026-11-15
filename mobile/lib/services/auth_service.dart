import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _client.setToken(token);
    await _saveUser(userData);

    return UserModel.fromJson(userData);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _client.setToken(token);
    await _saveUser(userData);

    return UserModel.fromJson(userData);
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', {});
    } catch (_) {
      // Ignora falhas de rede ao desconectar
    } finally {
      await _client.setToken(null);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(AppConstants.userStorageKey);
    if (rawUser == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _client.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userStorageKey, jsonEncode(userData));
  }
}
