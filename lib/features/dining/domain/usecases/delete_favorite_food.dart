import 'package:fpdart/src/either.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class DeleteFavoriteFood implements UseCase<void, DeleteFavoriteFoodParams> {
  final DiningRepository diningRepository;
  DeleteFavoriteFood(this.diningRepository);

  @override
  Future<Either<Failure, void>> call(DeleteFavoriteFoodParams params) async {
    return await diningRepository.deleteFavoriteFood(foodId: params.foodId);
  }
}

class DeleteFavoriteFoodParams {
  final int foodId;

  DeleteFavoriteFoodParams(this.foodId);
}
