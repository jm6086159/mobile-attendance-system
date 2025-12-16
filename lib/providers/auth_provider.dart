import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _initializing = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitializing => _initializing;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  Future<void> initialize() async {
    _initializing = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');
      if (token != null && userJson != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
    } catch (_) {}
    _initializing = false;
    notifyListeners();
  }

  Future<bool> login({String? email, String? empCode, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final res = await ApiService.login(email: email, empCode: empCode, password: password);
    if (res['success'] == true) {
      final token = res['token'] as String?;
      final userMap = res['user'] as Map<String, dynamic>?;
      if (token != null && userMap != null) {
        _token = token;
        _user = User.fromJson(userMap);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Malformed response';
    } else {
      _error = res['message']?.toString() ?? 'Invalid credentials';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }
}

