import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetFoodDetails {
  final DiningRepository diningRepository;

  GetFoodDetails(this.diningRepository);

  Future<Either<Failure, List<Food>>> call(GetFoodDetailsParams params) async {
    return await diningRepository.getFoodById(
      id: params.id,
      date: params.date,
      diningHall: params.diningHall,
    );
  }
}

class GetFoodDetailsParams {
  final int id;
  final String? diningHall;
  final DateTime? date;

  GetFoodDetailsParams({
    required this.id,
    this.diningHall,
    this.date,
  });
}
