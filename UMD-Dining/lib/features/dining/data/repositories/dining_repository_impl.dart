import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/network/connection_checker.dart';
import 'package:umd_dining_refactor/features/dining/data/datasources/dining_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class DiningRepositoryImpl implements DiningRepository {
  final DiningRemoteDataSource diningRemoteDataSource;
  // final DiningLocalDataSource diningLocalDataSource;
  final ConnectionChecker connectionChecker;
  DiningRepositoryImpl(
    this.diningRemoteDataSource,
    // this.diningLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<Food>>> getFoodsByFilters({
    List<String>? mealTypes,
    List<String>? diningHalls,
    List<String>? sections,
    List<String>? dates,
    List<String>? allergens,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final food = await diningRemoteDataSource.getFoodsByFilters(
        mealTypes: mealTypes,
        diningHalls: diningHalls,
        sections: sections,
        dates: dates,
        allergens: allergens,
      );
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Food>> getFoodById({required int foodId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final food = await diningRemoteDataSource.getFoodById(id: foodId);
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addFavoriteFood({required int foodId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await diningRemoteDataSource.addFavoriteFood(foodId: foodId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFavoriteFood({required int foodId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await diningRemoteDataSource.deleteFavoriteFood(foodId: foodId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Food>>> fetchFavoriteFoods() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final foods = await diningRemoteDataSource.fetchFavoriteFoods();
      return right(foods);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
