import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetFoodsByFilters implements UseCase<List<Food>, GetFoodsByFiltersParams> {
  final DiningRepository diningRepository;
  GetFoodsByFilters(this.diningRepository);

  @override
  Future<Either<Failure, List<Food>>> call(GetFoodsByFiltersParams params) async {
    final result = await diningRepository.getFoodsByFilters(
      diningHalls: params.diningHalls,
      sections: params.sections,
      mealTypes: params.mealTypes,
      dates: params.dates,
      allergens: params.allergens,
    );
    return result;
  }
}

class GetFoodsByFiltersParams {
  final List<String>? dates;
  final List<String>? diningHalls;
  final List<String>? sections;
  final List<String>? mealTypes;
  final List<String>? allergens;

  GetFoodsByFiltersParams({
    this.dates,
    this.diningHalls,
    this.sections,
    this.mealTypes,
    this.allergens,
  });
}
