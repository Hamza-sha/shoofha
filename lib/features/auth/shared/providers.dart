import 'package:flutter_riverpod/legacy.dart';
import 'package:shoofha/features/auth/application/auth_notifier.dart';

/// تقدر تستخدم هذا في أي Widget:
/// ref.watch(authNotifierProvider).isLoggedIn
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return authNotifier;
});
