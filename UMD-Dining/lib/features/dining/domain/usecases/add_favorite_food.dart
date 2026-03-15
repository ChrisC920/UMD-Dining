import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class AddFavoriteFood {
  final DiningRepository diningRepository;
  AddFavoriteFood(this.diningRepository);

  Future<Either<Failure, String>> call(AddFavoriteFoodParams params) async {
    return await diningRepository.addFavoriteFood(
      clerkId: params.clerkId,
      foodId: params.foodId,
    );
  }
}

class AddFavoriteFoodParams {
  final String clerkId;
  final String foodId;

  AddFavoriteFoodParams({required this.clerkId, required this.foodId});
}
