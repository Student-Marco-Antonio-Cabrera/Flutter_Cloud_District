import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/social_auth_service.dart';

const _keyUser = 'vapeshop_user';
const _keyLoggedIn = 'vapeshop_logged_in';

class AuthProvider with ChangeNotifier {
  AuthProvider(this._prefs) {
    _loadStoredUser();
  }

  final SharedPreferences _prefs;
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _loadStoredUser() async {
    final json = _prefs.getString(_keyUser);
    final loggedIn = _prefs.getBool(_keyLoggedIn) ?? false;
    if (json != null && loggedIn) {
      try {
        _user = User.fromJson(jsonDecode(json) as Map<String, dynamic>);
        _isLoggedIn = true;
      } catch (_) {
        _user = null;
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _user = User(
      id: id,
      email: email.trim(),
      displayName: email.split('@').first,
      phone: null,
      profileImagePath: null,
      addresses: [],
    );
    _isLoggedIn = true;
    await _prefs.setBool(_keyLoggedIn, true);
    await _prefs.setString(_keyUser, jsonEncode(_user!.toJson()));
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    if (email.trim().isEmpty || password.isEmpty || displayName.trim().isEmpty) {
      return false;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _user = User(
      id: id,
      email: email.trim(),
      displayName: displayName.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      profileImagePath: null,
      addresses: [],
    );
    _isLoggedIn = true;
    await _prefs.setBool(_keyLoggedIn, true);
    await _prefs.setString(_keyUser, jsonEncode(_user!.toJson()));
    notifyListeners();
    return true;
  }

  /// Sign in or register using Google/Facebook (no password).
  Future<bool> signInWithProvider({
    required String email,
    required String displayName,
  }) async {
    if (email.trim().isEmpty) return false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _user = User(
      id: id,
      email: email.trim(),
      displayName: displayName.trim().isEmpty ? email.split('@').first : displayName.trim(),
      phone: null,
      profileImagePath: null,
      addresses: [],
    );
    _isLoggedIn = true;
    await _prefs.setBool(_keyLoggedIn, true);
    await _prefs.setString(_keyUser, jsonEncode(_user!.toJson()));
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyLoggedIn);
    await SocialAuthService.signOutGoogle();
    await SocialAuthService.signOutFacebook();
    notifyListeners();
  }
}
