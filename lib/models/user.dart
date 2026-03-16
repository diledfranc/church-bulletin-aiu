enum UserRole { admin, clerk, user }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'role': role.name};
  }
}
