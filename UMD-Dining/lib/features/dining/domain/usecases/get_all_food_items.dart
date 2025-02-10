import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetAllFoods implements UseCase<List<Dining>, NoParams> {
  final DiningRepository diningRepository;
  GetAllFoods(this.diningRepository);

  @override
  Future<Either<Failure, List<Dining>>> call(NoParams params) async {
    return await diningRepository.getAllFoods();
  }
}
