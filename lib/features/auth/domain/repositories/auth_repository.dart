import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_preferences.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_profile.dart';

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

  Future<Either<Failure, User>> updateUserPreferences(
    UserPreferencesParams params,
  );

  Future<Either<Failure, User>> updateUserProfile(
    UserProfileParams params,
  );
}
