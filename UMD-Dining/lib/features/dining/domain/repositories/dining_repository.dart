import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

abstract interface class DiningRepository {
  Future<Either<Failure, List<Food>>> getFoodById({
    required String id,
    String? diningHall,
    DateTime? date,
  });
  Future<Either<Failure, List<Food>>> getFoodsByFilters({
    List<String>? mealTypes,
    List<String>? diningHalls,
    List<String>? sections,
    DateTime? date,
    List<String>? allergens,
  });
  Future<Either<Failure, String>> addFavoriteFood({required String clerkId, required String foodId});
  Future<Either<Failure, String>> deleteFavoriteFood({required String clerkId, required String foodId});
  Future<Either<Failure, List<Food>>> fetchFavoriteFoods({required String clerkId});
}
