class User {
  final String id;
  final String name;
  final String email;
  final String? empCode;

  User({required this.id, required this.name, required this.email, this.empCode});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] ?? '').toString(),
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        empCode: j['emp_code'] ?? j['empCode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'emp_code': empCode,
      };
}

