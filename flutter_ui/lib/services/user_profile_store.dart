import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'auth_service.dart';

class UserProfileStore extends ChangeNotifier {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  User? _user;

  User? get user => _user;

  Future<User?> load() async {
    final user = await AuthService.me();
    if (user != null) update(user);
    return user;
  }

  void update(User user) {
    _user = user;
    notifyListeners();
  }
}
