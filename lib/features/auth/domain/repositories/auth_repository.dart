import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithGoogleOAuth();

  Future<Either<Failure, User>> loginWithAppleOAuth();

  Future<Either<Failure, User>> currentUser();
}
