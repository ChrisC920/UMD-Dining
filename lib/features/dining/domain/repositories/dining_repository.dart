import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

abstract interface class DiningRepository {
  Future<Either<Failure, Food>> getFoodById({required int foodId});
  Future<Either<Failure, List<Food>>> getFoodsByFilters({
    List<String>? mealTypes,
    List<String>? diningHalls,
    List<String>? sections,
    List<String>? dates,
    List<String>? allergens,
  });
  Future<Either<Failure, void>> addFavoriteFood({required int foodId});
  Future<Either<Failure, void>> deleteFavoriteFood({required int foodId});
  Future<Either<Failure, List<Food>>> fetchFavoriteFoods();
}
