import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class AddFavoriteFood implements UseCase<void, AddFavoriteFoodParams> {
  final DiningRepository diningRepository;
  AddFavoriteFood(this.diningRepository);

  @override
  Future<Either<Failure, void>> call(AddFavoriteFoodParams params) async {
    return await diningRepository.addFavoriteFood(foodId: params.foodId);
  }
}

class AddFavoriteFoodParams {
  final int foodId;

  AddFavoriteFoodParams(this.foodId);
}
