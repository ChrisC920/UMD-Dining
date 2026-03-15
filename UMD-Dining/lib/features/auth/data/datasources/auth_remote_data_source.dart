import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/features/auth/data/models/user_model.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_preferences.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_profile.dart';

abstract interface class AuthRemoteDataSource {
  /// Pass the ClerkAuthState from the widget layer to get the current user.
  Future<UserModel?> getCurrentUserData(ClerkAuthState authState);
  Future<UserModel> updateUserPreferences(UserPreferencesParams params);
  Future<UserModel> updateUserProfile(UserProfileParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ConvexClient convexClient;
  AuthRemoteDataSourceImpl(this.convexClient);

  @override
  Future<UserModel?> getCurrentUserData(ClerkAuthState authState) async {
    try {
      final user = authState.user;
      if (user == null) return null;

      final email = user.emailAddresses?.firstOrNull?.emailAddress ?? '';
      final name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

      // Upsert into Convex so the user record exists server-side
      print('[AuthDS] upserting user clerkId=${user.id} email=$email');
      await convexClient.mutation(name: 'users:upsertUser', args: {
        'clerkId': user.id,
        'email': email,
        'name': name,
      });
      print('[AuthDS] upsert complete');

      return UserModel(
        id: user.id,
        email: email,
        name: name,
        isNewUser: false,
      );
    } catch (e) {
      print('[AuthDS] upsert ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserPreferences(UserPreferencesParams params) async {
    try {
      await convexClient.mutation(name: 'users:upsertPreferences', args: {
        'clerkId': params.userId,
        'preferences': params.preferences,
      });
      return UserModel(id: params.userId, email: '', name: '', isNewUser: false);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserProfileParams params) async {
    throw const ServerException('updateUserProfile not yet implemented for Convex');
  }
}
