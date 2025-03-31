import 'package:umd_dining_refactor/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isNewUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isNewUser: map['isNewUser'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isNewUser,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
