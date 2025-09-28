class User {
  final String name;
  final String lastName;
  String role; // ✅ Cambiado de final a mutable
  final String documentNumber;
  String status; // ✅ Ya es mutable

  User({
    required this.name,
    required this.lastName,
    required this.role,
    required this.documentNumber,
    this.status = 'Activo',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return User(
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? 'Usuario',
      documentNumber: data['documentNumber'] ?? '',
      status: data['status'] ?? 'Activo',
    );
  }

  String get fullName => '$name $lastName';
}