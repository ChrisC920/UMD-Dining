import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class DeleteFavoriteFood {
  final DiningRepository diningRepository;
  DeleteFavoriteFood(this.diningRepository);

  Future<Either<Failure, String>> call(DeleteFavoriteFoodParams params) async {
    return await diningRepository.deleteFavoriteFood(
      clerkId: params.clerkId,
      foodId: params.foodId,
    );
  }
}

class DeleteFavoriteFoodParams {
  final String clerkId;
  final String foodId;

  DeleteFavoriteFoodParams({required this.clerkId, required this.foodId});
}
