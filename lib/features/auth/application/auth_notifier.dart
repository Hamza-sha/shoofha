import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// موديل بسيط للمستخدم (مؤقت لحد ما تربطه مع API حقيقي)
class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
    id: (map['id'] ?? '') as String,
    name: (map['name'] ?? '') as String,
    email: (map['email'] ?? '') as String,
  );
}

/// Notifier مركزي لحالة اليوزر + فلو الاهتمامات + حفظ الحالة (Persist)
class AuthNotifier extends ChangeNotifier {
  static const _kUserJson = 'shoofha_auth_user_json';
  static const _kCompletedInterests = 'shoofha_completed_interests';

  AuthUser? _user;
  bool _hasCompletedInterests = false;

  // -------- Getters --------
  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get hasCompletedInterests => _hasCompletedInterests;

  /// ✅ استرجاع الحالة عند تشغيل التطبيق
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

  // -------- LOGIN (مستخدم عنده حساب) --------
  Future<void> signIn({required String email, required String password}) async {
    // TODO: استبدل هذا ب API حقيقي لاحقاً
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _user = AuthUser(
      id: 'user-login-${DateTime.now().millisecondsSinceEpoch}',
      name: email.contains('@') ? email.split('@').first : 'Shoofha User',
      email: email.isNotEmpty ? email : 'user@shoofha.local',
    );

    // مستخدم قديم → نفترض مكمّل اهتمامات
    _hasCompletedInterests = true;

    await _persist();
    notifyListeners();
  }

  // -------- SIGNUP (مستخدم جديد) --------
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // TODO: API create user
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _user = AuthUser(
      id: 'user-signup-${DateTime.now().millisecondsSinceEpoch}',
      name: name.isNotEmpty ? name : 'Shoofha User',
      // لو ما في إيميل نخترع واحد محلي عشان باقي الشاشات ما تنكسر
      email: email.isNotEmpty ? email : '$phone@shoofha.local',
    );

    // مستخدم جديد → مسجّل دخول لكن لسه ما كمل اهتمامات + رايح OTP
    _hasCompletedInterests = false;

    await _persist();
    notifyListeners();
  }

  // -------- بعد ما ينجح OTP --------
  void verifyOtpSuccess() {
    if (_user == null) return;

    // مسجّل دخول + لسه ما كمل اهتمامات
    _hasCompletedInterests = false;
    notifyListeners();
    _persist(); // fire & forget
  }

  // -------- بعد اختيار الاهتمامات --------
  void completeInterests() {
    _hasCompletedInterests = true;
    notifyListeners();
    _persist(); // fire & forget
  }

  // -------- LOGOUT --------
  void logOut() {
    _user = null;
    _hasCompletedInterests = false;
    notifyListeners();
    _persist(); // fire & forget
  }
}

/// Singleton global يستخدمه الراوتر والشاشات
final AuthNotifier authNotifier = AuthNotifier();
