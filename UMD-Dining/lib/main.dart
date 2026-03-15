import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/config/themes/app_theme.dart';
import 'package:umd_dining_refactor/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:umd_dining_refactor/core/common/entities/user.dart';
import 'package:umd_dining_refactor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/auth/presentation/pages/signin_page.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/main_shell.dart';
import 'package:umd_dining_refactor/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: const String.fromEnvironment(
          'CLERK_PUBLISHABLE_KEY',
          defaultValue: 'pk_test_ZGVlcC1mbHktMTMuY2xlcmsuYWNjb3VudHMuZGV2JA',
        ),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
          BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
          BlocProvider(create: (_) => serviceLocator<DiningBloc>()),
        ],
        child: MaterialApp(
          showPerformanceOverlay: false,
          debugShowCheckedModeBanner: false,
          title: 'UMD Dining',
          theme: AppTheme.lightTheme,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _syncDispatched = false;

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        final clerkUser = authState.user;
        if (clerkUser != null) {
          final user = User(
            id: clerkUser.id,
            email: clerkUser.emailAddresses?.firstOrNull?.emailAddress ?? '',
            name: '${clerkUser.firstName ?? ''} ${clerkUser.lastName ?? ''}'.trim(),
            isNewUser: false,
          );
          context.read<AppUserCubit>().updateUser(user);
        }

        if (!_syncDispatched) {
          _syncDispatched = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<AuthBloc>().add(AuthIsUserLoggedIn(authState));
            }
          });
        }

        return BlocSelector<AppUserCubit, AppUserState, bool>(
          selector: (state) => state is AppUserLoggedIn,
          builder: (context, isLoggedIn) {
            if (isLoggedIn) return const MainShell();
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
      signedOutBuilder: (context, authState) {
        _syncDispatched = false;
        context.read<AppUserCubit>().updateUser(null);
        return const SignInPage();
      },
    );
  }
}
