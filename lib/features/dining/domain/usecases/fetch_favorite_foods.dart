import 'package:fpdart/src/either.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class FetchFavoriteFoods implements UseCase<List<Food>, NoParams> {
  final DiningRepository diningRepository;
  FetchFavoriteFoods(this.diningRepository);

  @override
  Future<Either<Failure, List<Food>>> call(NoParams params) async {
    return await diningRepository.fetchFavoriteFoods();
  }
}
