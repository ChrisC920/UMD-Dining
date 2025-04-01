import 'package:fpdart/src/either.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetFoodDetails {
  final DiningRepository diningRepository;

  GetFoodDetails(this.diningRepository);

  Future<Either<Failure, Food>> call(GetFoodDetailsParams params) async {
    return await diningRepository.getFoodById(foodId: params.foodId);
  }
}

class GetFoodDetailsParams {
  final int foodId;

  GetFoodDetailsParams({
    required this.foodId,
  });
}
