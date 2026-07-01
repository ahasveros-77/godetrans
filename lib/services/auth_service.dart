import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'sheets_api_service.dart';

class AuthService {
  static const String _sessionKey = 'godetrans_session_user';

  /// Registrasi user baru. Mengirim ke sheet "Users" via Apps Script.
  static Future<UserModel> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
  }) async {
    final result = await SheetsApiService.post('register', {
      'nama': nama,
      'email': email,
      'password': password,
      'no_hp': noHp,
    });
    final user = UserModel.fromJson(Map<String, dynamic>.from(result));
    await _saveSession(user);
    return user;
  }

  /// Login dengan email & password, dicocokkan ke sheet "Users".
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await SheetsApiService.post('login', {
      'email': email,
      'password': password,
    });
    final user = UserModel.fromJson(Map<String, dynamic>.from(result));
    await _saveSession(user);
    return user;
  }

  static Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Menandai bahwa onboarding sudah pernah dilihat, agar tidak diulang.
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }
}
