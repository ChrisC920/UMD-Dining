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
    DateTime? date,
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
        date: date,
        allergens: allergens,
      );
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Food>>> getFoodById({required int id, String? diningHall, DateTime? date}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final food = await diningRemoteDataSource.getFoodById(id: id, diningHall: diningHall, date: date);
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> addFavoriteFood({required int foodId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await diningRemoteDataSource.addFavoriteFood(foodId: foodId);
      return right(foodId);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> deleteFavoriteFood({required int foodId}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await diningRemoteDataSource.deleteFavoriteFood(foodId: foodId);
      return right(foodId);
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
