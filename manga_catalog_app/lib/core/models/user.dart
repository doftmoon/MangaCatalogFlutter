import '../enums/user_role.dart';

class AppUser {
  final String uid;
  final String? email;
  final UserRole role;

  AppUser({required this.uid, this.email, required this.role});
}
