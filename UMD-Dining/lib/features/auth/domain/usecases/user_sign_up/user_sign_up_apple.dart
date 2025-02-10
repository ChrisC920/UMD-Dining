import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUpApple implements UseCase<User, NoParams> {
  final AuthRepository authRepository;
  const UserSignUpApple(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.loginWithAppleOAuth();
  }
}
