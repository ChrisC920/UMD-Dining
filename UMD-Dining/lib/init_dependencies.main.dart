part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize ConvexClient singleton (must be called before use)
  await ConvexClient.initialize(const ConvexConfig(
    deploymentUrl: Constants.convexUrl,
    clientId: 'umd-dining',
  ));

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => const ConnectionCheckerImpl(),
  );

  _initAuth();
  _initDining();
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(ConvexClient.instance),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUpEmail(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignUpGoogle(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignUpApple(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateUserPreferences(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateUserProfile(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUpEmail: serviceLocator(),
        userSignUpGoogle: serviceLocator(),
        userSignUpApple: serviceLocator(),
        userLogin: serviceLocator(),
        updateUserPreferences: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        updateUserProfile: serviceLocator(),
      ),
    );
}

void _initDining() {
  // Datasource
  serviceLocator
    ..registerFactory<DiningRemoteDataSource>(
      () => DiningRemoteDataSourceImpl(ConvexClient.instance),
    )
    // ..registerFactory<DiningLocalDataSource>(
    //   () => DiningLocalDataSourceImpl(serviceLocator()),
    // )

    // Repository
    ..registerFactory<DiningRepository>(
      () => DiningRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetFoodDetails(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFoodsByFilters(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddFavoriteFood(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DeleteFavoriteFood(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => FetchFavoriteFoods(
        serviceLocator(),
      ),
    )

    // Bloc
    ..registerLazySingleton(
      () => DiningBloc(
        getFoodDetails: serviceLocator(),
        getFoodsByFilters: serviceLocator(),
        addFavoriteFood: serviceLocator(),
        deleteFavoriteFood: serviceLocator(),
        fetchFavoriteFoods: serviceLocator(),
      ),
    );
}
