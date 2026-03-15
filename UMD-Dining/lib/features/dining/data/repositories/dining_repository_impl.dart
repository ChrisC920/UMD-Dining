import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/data/datasources/dining_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class DiningRepositoryImpl implements DiningRepository {
  final DiningRemoteDataSource diningRemoteDataSource;

  DiningRepositoryImpl(this.diningRemoteDataSource);

  @override
  Future<Either<Failure, List<Food>>> getFoodsByFilters({
    List<String>? mealTypes,
    List<String>? diningHalls,
    List<String>? sections,
    DateTime? date,
    List<String>? allergens,
  }) async {
    try {
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
  Future<Either<Failure, List<Food>>> getFoodById({
    required String id,
    String? diningHall,
    DateTime? date,
  }) async {
    try {
      final food = await diningRemoteDataSource.getFoodById(
        id: id,
        diningHall: diningHall,
        date: date,
      );
      return right(food);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> addFavoriteFood({
    required String clerkId,
    required String foodId,
  }) async {
    try {
      final result = await diningRemoteDataSource.addFavoriteFood(
        clerkId: clerkId,
        foodId: foodId,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> deleteFavoriteFood({
    required String clerkId,
    required String foodId,
  }) async {
    try {
      final result = await diningRemoteDataSource.deleteFavoriteFood(
        clerkId: clerkId,
        foodId: foodId,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Food>>> fetchFavoriteFoods({
    required String clerkId,
  }) async {
    try {
      final foods = await diningRemoteDataSource.fetchFavoriteFoods(
        clerkId: clerkId,
      );
      return right(foods);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
