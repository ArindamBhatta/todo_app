class AuthUser {
  final String displayName;
  final String? photoUrl;
  final String? email;

  const AuthUser({
    required this.displayName,
    this.photoUrl,
    this.email,
  });
}
