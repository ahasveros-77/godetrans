class UserModel {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String role;
  final String? password;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      password: json['password']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'role': role,
      'password': password,
    };
  }
}
