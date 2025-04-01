import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfile implements UseCase<User, UserProfileParams> {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UserProfileParams params) async {
    return repository.updateUserProfile(params);
  }
}

class UserProfileParams {
  final String userId;
  final int age;

  UserProfileParams({
    required this.userId,
    required this.age,
  });

  // Optional: Convert to JSON for debugging or logging
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'age': age,
    };
  }
}
