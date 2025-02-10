import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetFood implements UseCase<Dining, GetFoodParams> {
  final DiningRepository diningRepository;
  GetFood(this.diningRepository);

  @override
  Future<Either<Failure, Dining>> call(GetFoodParams params) async {
    return await diningRepository.getFood(name: params.name);
  }
}

class GetFoodParams {
  final String name;

  GetFoodParams({
    required this.name,
  });
}
