class UserModel {
  final String? name;
  final String? businessName;
  final String? role;
  final String email;
  final String? phone;

  UserModel({
    this.name,
    this.businessName,
    this.role,
    required this.email,
    this.phone,
  });

  factory UserModel.fromMap(String email, Map<String, dynamic> data) {
    return UserModel(
      email: email,
      name: data['name'],
      businessName: data['businessName'],
      role: data['role'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'businessName': businessName,
      'role': role,
      'email': email,
      'phone': phone,
    };
  }
}
