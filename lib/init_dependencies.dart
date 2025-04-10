import 'package:umd_dining_refactor/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:umd_dining_refactor/core/network/connection_checker.dart';
import 'package:umd_dining_refactor/core/secrets/secret.dart';

// Auth imports
import 'package:umd_dining_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:umd_dining_refactor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:umd_dining_refactor/features/auth/domain/repositories/auth_repository.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/current_user.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_preferences.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/update_user_profile.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_login.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_apple.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_email.dart';
import 'package:umd_dining_refactor/features/auth/domain/usecases/user_sign_up/user_sign_up_google.dart';
import 'package:umd_dining_refactor/features/auth/presentation/bloc/auth_bloc.dart';

// Dining imports
import 'package:umd_dining_refactor/features/dining/data/datasources/dining_remote_data_source.dart';
// import 'package:umd_dining_refactor/features/dining/data/datasources/dining_local_data_source.dart';
import 'package:umd_dining_refactor/features/dining/data/repositories/dining_repository_impl.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/add_favorite_food.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/delete_favorite_food.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/fetch_favorite_foods.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food_details.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_foods_by_query.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'init_dependencies.main.dart';
