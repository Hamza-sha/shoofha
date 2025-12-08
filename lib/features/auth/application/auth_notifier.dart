import 'package:flutter/foundation.dart';

/// موديل بسيط للمستخدم (مؤقت لحد ما تربطه مع API حقيقي)
class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({required this.id, required this.name, required this.email});
}

/// Notifier مركزي لحالة اليوزر + فلو الاهتمامات
class AuthNotifier extends ChangeNotifier {
  AuthUser? _user;
  bool _hasCompletedInterests = false;

  // -------- Getters --------
  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get hasCompletedInterests => _hasCompletedInterests;

  // -------- LOGIN (مستخدم عنده حساب) --------
  Future<void> signIn({required String email, required String password}) async {
    // TODO: استبدل هذا ب API حقيقي لاحقاً
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _user = AuthUser(
      id: 'user-login-id',
      name: email.split('@').first,
      email: email,
    );

    // مستخدم قديم → نفترض مكمّل اهتمامات
    _hasCompletedInterests = true;

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

    // مستخدم جديد → مسجّل دخول لكن لسه ما كمل اهتمامات + رايح OTP
    _user = AuthUser(
      id: 'user-signup-id',
      name: name,
      email: email.isNotEmpty ? email : '$phone@shoofha.local',
    );

    _hasCompletedInterests = false;
    notifyListeners();
  }

  // -------- بعد ما ينجح OTP --------
  void verifyOtpSuccess() {
    if (_user != null) {
      // مسجّل دخول + لسه ما كمل اهتمامات
      _hasCompletedInterests = false;
      notifyListeners();
    }
  }

  // -------- بعد اختيار الاهتمامات --------
  void completeInterests() {
    _hasCompletedInterests = true;
    notifyListeners();
  }

  // -------- LOGOUT --------
  void logOut() {
    _user = null;
    _hasCompletedInterests = false;
    notifyListeners();
  }
}

/// Singleton global يستخدمه الراوتر والشاشات
final AuthNotifier authNotifier = AuthNotifier();
