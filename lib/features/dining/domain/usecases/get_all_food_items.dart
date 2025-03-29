import 'package:fpdart/fpdart.dart';
import 'package:umd_dining_refactor/core/errors/failures.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/repositories/dining_repository.dart';

class GetAllFoods implements UseCase<List<Dining>, GetDatabaseParams> {
  final DiningRepository diningRepository;
  GetAllFoods(this.diningRepository);

  @override
  Future<Either<Failure, List<Dining>>> call(GetDatabaseParams params) async {
    return await diningRepository.getAllFoods(database: params.database);
  }
}

class GetDatabaseParams {
  final String database;

  GetDatabaseParams({
    required this.database,
  });
}
