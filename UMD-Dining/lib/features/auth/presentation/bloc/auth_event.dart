part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthSignUpEmail extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpEmail({
    required this.email,
    required this.password,
    required this.name,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin({
    required this.email,
    required this.password,
  });
}

final class UpdateUserPreferencesEvent extends AuthEvent {
  final String userId;
  final Map<String, bool> preferences;

  const UpdateUserPreferencesEvent({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object> get props => [userId, preferences];
}

final class AuthSignUpGoogle extends AuthEvent {}

final class AuthSignUpApple extends AuthEvent {}

final class AuthIsUserLoggedIn extends AuthEvent {}
