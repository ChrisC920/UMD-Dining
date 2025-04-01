part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);
  @override
  List<Object> get props => [user, user.id];
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

final class AuthNewUser extends AuthState {
  final User user;
  const AuthNewUser(this.user);
  @override
  List<Object> get props => [user, user.id];
}
