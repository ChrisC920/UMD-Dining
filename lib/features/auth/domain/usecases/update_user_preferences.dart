import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserPreferencesUseCase
    implements UseCase<User, UserPreferencesParams> {
  final AuthRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UserPreferencesParams params) {
    return repository.updateUserPreferences(params);
  }
}

class UserPreferencesParams {
  final String userId;
  final Map<String, bool> preferences;

  UserPreferencesParams({
    required this.userId,
    required this.preferences,
  });
}
