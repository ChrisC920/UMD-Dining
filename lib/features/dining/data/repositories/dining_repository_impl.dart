import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/network/connection_checker.dart';
import 'package:umd_dining_refactor/features/dining/data/datasources/dining_remote_data_source.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
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
  Future<Either<Failure, List<Dining>>> getAllFoods({required String database}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final foods = await diningRemoteDataSource.getAllFoods(database: database);
      return right(foods);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Dining>> getFood({
    required String name,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final food = await diningRemoteDataSource.getFood(name: name);
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Dining>>> getFoodQuery({
    int? id,
    DateTime? createdAt,
    String? name,
    List<String>? diningHall,
    List<String>? section,
    List<String>? mealType,
    String? link,
    String? servingSize,
    String? servingsPerContainer,
    String? caloriesPerServing,
    String? totalFat,
    String? saturatedFat,
    String? transFat,
    String? cholesterol,
    String? sodium,
    String? totalCarbohydrates,
    String? dietaryFiber,
    String? totalSugar,
    String? addedSugar,
    String? protein,
    List<String>? allergens,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final food = await diningRemoteDataSource.getFoodQuery(
        name: name,
        link: link,
        servingSize: servingSize,
        servingsPerContainer: servingsPerContainer,
        caloriesPerServing: caloriesPerServing,
        totalFat: totalFat,
        saturatedFat: saturatedFat,
        transFat: transFat,
        cholesterol: cholesterol,
        sodium: sodium,
        totalCarbohydrates: totalCarbohydrates,
        dietaryFiber: dietaryFiber,
        totalSugar: totalSugar,
        addedSugar: addedSugar,
        protein: protein,
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
}
