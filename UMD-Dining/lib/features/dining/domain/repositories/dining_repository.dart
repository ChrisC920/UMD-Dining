import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DiningRepository {
  Future<Either<Failure, List<Dining>>> getAllFoods({required String database});
  Future<Either<Failure, Dining>> getFood({required String name});
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
  });
}
