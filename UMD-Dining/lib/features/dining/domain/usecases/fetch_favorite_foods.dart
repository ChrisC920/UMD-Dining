import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class FetchFavoriteFoods {
  final DiningRepository diningRepository;
  FetchFavoriteFoods(this.diningRepository);

  Future<Either<Failure, List<Food>>> call(String clerkId) async {
    return await diningRepository.fetchFavoriteFoods(clerkId: clerkId);
  }
}
