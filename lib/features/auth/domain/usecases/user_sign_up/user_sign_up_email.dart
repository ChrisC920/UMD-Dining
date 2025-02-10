import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUpEmail implements UseCase<User, UserSignUpEmailParams> {
  final AuthRepository authRepository;
  const UserSignUpEmail(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpEmailParams params) async {
    return await authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpEmailParams {
  final String email;
  final String password;
  final String name;
  UserSignUpEmailParams({
    required this.email,
    required this.password,
    required this.name,
  });
}
