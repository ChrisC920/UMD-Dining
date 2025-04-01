import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/network/connection_checker.dart';
import 'package:umd_dining_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/data/models/user_model.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure('User not logged in!'));
        }

        final userExists = await _checkIfUserExists(session.user.id);

        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
            isNewUser: !userExists,
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> loginWithGoogleOAuth() async {
    return _getUser(
      () async {
        final user = await remoteDataSource.loginWithGoogleOAuth();
        final isNewUser = await _checkIfUserExists(user.id);

        return user.copyWith(isNewUser: isNewUser);
      },
    );
  }

  @override
  Future<Either<Failure, User>> loginWithAppleOAuth() async {
    return _getUser(
      () async => await remoteDataSource.loginWithAppleOAuth(),
    );
  }

  @override
  Future<Either<Failure, User>> updateUserPreferences(
      UserPreferencesParams params) async {
    try {
      final updatedUser = await remoteDataSource.updateUserPreferences(params);
      return Right(updatedUser);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await fn();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  Future<bool> _checkIfUserExists(String userId) async {
    final response = await Constants.supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return response != null; // If null, user does not exist
  }
}
