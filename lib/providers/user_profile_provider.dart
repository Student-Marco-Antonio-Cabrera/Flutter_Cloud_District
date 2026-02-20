import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address.dart';
import 'auth_provider.dart';

const _keyProfile = 'vapeshop_profile';

class UserProfileProvider with ChangeNotifier {
  UserProfileProvider(this._prefs, this._authProvider) {
    _authProvider.addListener(_onAuthChanged);
    _loadProfile();
  }

  final SharedPreferences _prefs;
  final AuthProvider _authProvider;

  String? _displayName;
  String? _phone;
  String? _profileImagePath;
  List<Address> _addresses = [];

  String? get displayName => _displayName ?? _authProvider.user?.displayName;
  String? get phone => _phone ?? _authProvider.user?.phone;
  String? get profileImagePath => _profileImagePath;
  List<Address> get addresses => List.unmodifiable(_addresses);

  void _onAuthChanged() {
    if (!_authProvider.isLoggedIn) {
      _displayName = null;
      _phone = null;
      _profileImagePath = null;
      _addresses = [];
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final json = _prefs.getString(_keyProfile);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _displayName = map['displayName'] as String?;
        _phone = map['phone'] as String?;
        _profileImagePath = map['profileImagePath'] as String?;
        final addrList = map['addresses'] as List<dynamic>?;
        _addresses = addrList
                ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      } catch (_) {}
    } else if (_authProvider.user != null) {
      _displayName = _authProvider.user!.displayName;
      _phone = _authProvider.user!.phone;
      _addresses = List.from(_authProvider.user!.addresses);
    }
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final map = <String, dynamic>{
      'displayName': displayName,
      'phone': phone,
      'profileImagePath': profileImagePath,
      'addresses': _addresses.map((a) => a.toJson()).toList(),
    };
    await _prefs.setString(_keyProfile, jsonEncode(map));
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? profileImagePath,
  }) async {
    if (displayName != null) _displayName = displayName;
    if (phone != null) _phone = phone;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    await _saveProfile();
  }

  Future<void> setProfileImage(String? path) async {
    _profileImagePath = path;
    await _saveProfile();
  }

  Future<void> addAddress(Address address) async {
    _addresses.add(address);
    await _saveProfile();
  }

  Future<void> updateAddress(int index, Address address) async {
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = address;
      await _saveProfile();
    }
  }

  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      _addresses.removeAt(index);
      await _saveProfile();
    }
  }

  Address? getAddressById(String id) {
    try {
      return _addresses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
