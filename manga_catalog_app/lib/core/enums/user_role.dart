enum UserRole { guest, user, admin, moderator, editor }

UserRole userRoleFromString(String? roleString) {
  if (roleString == null) return UserRole.guest;
  switch (roleString.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'editor':
      return UserRole.editor;
    case 'moderator':
      return UserRole.moderator;
    case 'user':
      return UserRole.user;
    default:
      return UserRole.user;
  }
}

String userRoleToString(UserRole role) {
  return role.toString().split('.').last;
}
