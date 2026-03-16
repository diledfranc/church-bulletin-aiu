class Contact {
  final String id;
  final String name;
  final String role;
  final String phoneNumber;
  final String email;

  Contact({
    required this.id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.email,
  });

  factory Contact.fromMap(Map<String, dynamic> data, String id) {
    return Contact(
      id: id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
