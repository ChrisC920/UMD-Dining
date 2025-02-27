part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initDining();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerLazySingleton(
    () => Hive.box(name: 'foods'),
  );

  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
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
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUpEmail: serviceLocator(),
        userSignUpGoogle: serviceLocator(),
        userSignUpApple: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initDining() {
  // Datasource
  serviceLocator
    ..registerFactory<DiningRemoteDataSource>(
      () => DiningRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // ..registerFactory<DiningLocalDataSource>(
    //   () => DiningLocalDataSourceImpl(serviceLocator()),
    // )

    // Repository
    ..registerFactory<DiningRepository>(
      () => DiningRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        // serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => GetAllFoods(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFood(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFoodQuery(
        serviceLocator(),
      ),
    )

    // Bloc
    ..registerLazySingleton(
      () => DiningBloc(
        getAllFoods: serviceLocator(),
        getFood: serviceLocator(),
        getFoodQuery: serviceLocator(),
      ),
    );
}
