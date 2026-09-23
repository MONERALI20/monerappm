class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String password;
  final String role;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.password,
    required this.role,
  });

  bool validateLogin(String enteredUser, String enteredPassword) {
    return username == enteredUser && password == enteredPassword;
  }
}
