import 'package:chat/generated/dsql.dart';

extension UserDto on UserEntity {
  Map<String, dynamic> toResponse() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
