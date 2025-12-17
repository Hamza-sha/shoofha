// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUserJson = 'shoofha_user_json';
const _kCompletedInterests = 'shoofha_completed_interests';

class AuthUser {
  final String id;
  final String name;
  final String email;

  // ✅ NEW
  final bool isGuest;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.isGuest = false,
  });

  factory AuthUser.guest() {
    return AuthUser(
      id: 'guest',
      name: 'Guest',
      email: 'guest@shoofha.local',
      isGuest: true,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'isGuest': isGuest,
  };

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
    id: (map['id'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    isGuest: (map['isGuest'] ?? false) == true,
  );
}

class AuthNotifier extends ChangeNotifier {
  AuthUser? _user;
  bool _hasCompletedInterests = false;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;

  // ✅ NEW
  bool get isGuest => _user?.isGuest == true;

  bool get hasCompletedInterests => _hasCompletedInterests;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_kUserJson);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _user = AuthUser.fromMap(map);
      } catch (_) {
        _user = null;
      }
    }

    _hasCompletedInterests = prefs.getBool(_kCompletedInterests) ?? false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    if (_user == null) {
      await prefs.remove(_kUserJson);
    } else {
      await prefs.setString(_kUserJson, jsonEncode(_user!.toMap()));
    }

    await prefs.setBool(_kCompletedInterests, _hasCompletedInterests);
  }

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _user = AuthUser(
      id: 'user-login-${DateTime.now().millisecondsSinceEpoch}',
      name: email.contains('@') ? email.split('@').first : 'Shoofha User',
      email: email.isNotEmpty ? email : 'user@shoofha.local',
      isGuest: false,
    );

    _hasCompletedInterests = true;

    await _persist();
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _user = AuthUser(
      id: 'user-signup-${DateTime.now().millisecondsSinceEpoch}',
      name: name.isNotEmpty ? name : 'Shoofha User',
      email: email.isNotEmpty ? email : '$phone@shoofha.local',
      isGuest: false,
    );

    _hasCompletedInterests = false;

    await _persist();
    notifyListeners();
  }

  void verifyOtpSuccess() {
    if (_user == null) return;
    _hasCompletedInterests = false;
    notifyListeners();
    _persist();
  }

  void completeInterests() {
    _hasCompletedInterests = true;
    notifyListeners();
    _persist();
  }

  // ✅ NEW: Continue as Guest
  Future<void> continueAsGuest() async {
    _user = AuthUser.guest();

    // Guest ما بدنا نعلّقه بالـ OTP/Interests
    _hasCompletedInterests = true;

    await _persist();
    notifyListeners();
  }

  Future<void> logOut() async {
    _user = null;
    _hasCompletedInterests = false;
    await _persist();
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();
