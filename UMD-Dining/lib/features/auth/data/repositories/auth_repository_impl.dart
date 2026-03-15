import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_preferences.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_profile.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> currentUser(ClerkAuthState authState) async {
    try {
      final user = await remoteDataSource.getCurrentUserData(authState);
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserPreferences(UserPreferencesParams params) async {
    try {
      final user = await remoteDataSource.updateUserPreferences(params);
      return Right(user);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(UserProfileParams params) async {
    try {
      final user = await remoteDataSource.updateUserProfile(params);
      return Right(user);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  // Sign-in/sign-up is handled by the ClerkAuthentication widget;
  // these methods are not called directly.
  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async => left(Failure('Use Clerk sign-in UI'));

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async => left(Failure('Use Clerk sign-in UI'));

  @override
  Future<Either<Failure, User>> loginWithGoogleOAuth() async =>
      left(Failure('Use Clerk sign-in UI'));

  @override
  Future<Either<Failure, User>> loginWithAppleOAuth() async =>
      left(Failure('Use Clerk sign-in UI'));
}
