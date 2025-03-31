import 'package:umd_dining_refactor/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/current_user.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_login.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_apple.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_google.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUpEmail _userSignUpEmail;
  final UserSignUpGoogle _userSignUpGoogle;
  final UserSignUpApple _userSignUpApple;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUpEmail userSignUpEmail,
    required UserSignUpGoogle userSignUpGoogle,
    required UserSignUpApple userSignUpApple,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignUpEmail = userSignUpEmail,
        _userSignUpGoogle = userSignUpGoogle,
        _userSignUpApple = userSignUpApple,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUpEmail>(_onAuthSignUpEmail);
    on<AuthSignUpGoogle>(_onAuthSignUpGoogle);
    on<AuthSignUpApple>(_onAuthSignUpApple);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUpEmail(
    AuthSignUpEmail event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUpEmail(
      UserSignUpEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthSignUpGoogle(
    AuthSignUpGoogle event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUpGoogle(NoParams());

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthSignUpApple(
    AuthSignUpApple event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUpApple(NoParams());

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);

    if (user.isNewUser) {
      emit(AuthNewUser(user));
    } else {
      emit(AuthSuccess(user));
    }
  }
}
