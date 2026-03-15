import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser {
  final AuthRepository authRepository;
  CurrentUser(this.authRepository);

  Future<Either<Failure, User>> call(ClerkAuthState authState) async {
    return await authRepository.currentUser(authState);
  }
}
