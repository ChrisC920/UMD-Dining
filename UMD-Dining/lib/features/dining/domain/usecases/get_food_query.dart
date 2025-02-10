import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetFoodQuery implements UseCase<List<Dining>, GetFoodQueryParams> {
  final DiningRepository diningRepository;
  GetFoodQuery(this.diningRepository);

  @override
  Future<Either<Failure, List<Dining>>> call(GetFoodQueryParams params) async {
    return await diningRepository.getFoodQuery(
      id: params.id,
      createdAt: params.createdAt,
      name: params.name,
      diningHall: params.diningHall,
      section: params.section,
      mealType: params.mealType,
      link: params.link,
      servingSize: params.servingSize,
      servingsPerContainer: params.servingsPerContainer,
      caloriesPerServing: params.caloriesPerServing,
      totalFat: params.totalFat,
      saturatedFat: params.saturatedFat,
      transFat: params.transFat,
      cholesterol: params.cholesterol,
      sodium: params.sodium,
      totalCarbohydrates: params.totalCarbohydrates,
      dietaryFiber: params.dietaryFiber,
      totalSugar: params.totalSugar,
      addedSugar: params.addedSugar,
      protein: params.protein,
      allergens: params.allergens,
    );
  }
}

class GetFoodQueryParams {
  final int? id;
  final DateTime? createdAt;
  final String? name;
  final List<String>? diningHall;
  final List<String>? section;
  final List<String>? mealType;
  final String? link;
  final String? servingSize;
  final String? servingsPerContainer;
  final String? caloriesPerServing;
  final String? totalFat;
  final String? saturatedFat;
  final String? transFat;
  final String? cholesterol;
  final String? sodium;
  final String? totalCarbohydrates;
  final String? dietaryFiber;
  final String? totalSugar;
  final String? addedSugar;
  final String? protein;
  final List<String>? allergens;

  GetFoodQueryParams({
    this.id,
    this.createdAt,
    this.name,
    this.diningHall,
    this.section,
    this.mealType,
    this.link,
    this.servingSize,
    this.servingsPerContainer,
    this.caloriesPerServing,
    this.totalFat,
    this.saturatedFat,
    this.transFat,
    this.cholesterol,
    this.sodium,
    this.totalCarbohydrates,
    this.dietaryFiber,
    this.totalSugar,
    this.addedSugar,
    this.protein,
    this.allergens,
  });
}
