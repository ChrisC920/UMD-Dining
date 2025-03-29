import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/core/usecases/usecase.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_all_food_items.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food_query.dart';
part 'dining_event.dart';
part 'dining_state.dart';

class DiningBloc extends Bloc<DiningEvent, DiningState> {
  final GetAllFoods _getAllFoods;
  final GetFood _getFood;
  final GetFoodQuery _getFoodQuery;

  DiningBloc({
    required GetAllFoods getAllFoods,
    required GetFood getFood,
    required GetFoodQuery getFoodQuery,
  })  : _getAllFoods = getAllFoods,
        _getFood = getFood,
        _getFoodQuery = getFoodQuery,
        super(DiningInitial()) {
    on<DiningEvent>((event, emit) => emit(DiningLoading()));
    on<DiningFetchAllFoods>(_onFetchAllFoods);
    on<DiningFetchFood>(_onFetchFood);
    on<DiningFetchFoodQuery>(_onFetchFoodQuery);
  }

  void _onFetchAllFoods(
    DiningFetchAllFoods event,
    Emitter<DiningState> emit,
  ) async {
    final res = await _getAllFoods(GetDatabaseParams(database: event.database));

    res.fold(
      (l) => emit(DiningFailure(l.message)),
      (r) => emit(DiningGetAllFoodsSuccess(r)),
    );
  }

  void _onFetchFood(
    DiningFetchFood event,
    Emitter<DiningState> emit,
  ) async {
    final res = await _getFood(
      GetFoodParams(name: event.name),
    );

    res.fold(
      (l) => emit(DiningFailure(l.message)),
      (r) => emit(DiningGetFoodSuccess(r)),
    );
  }

  void _onFetchFoodQuery(
    DiningFetchFoodQuery event,
    Emitter<DiningState> emit,
  ) async {
    final res = await _getFoodQuery(
      GetFoodQueryParams(
        id: event.id,
        createdAt: event.createdAt,
        name: event.name,
        diningHall: event.diningHall,
      ),
    );

    res.fold(
      (l) => emit(DiningFailure(l.message)),
      (r) => emit(DiningGetFoodQuerySuccess(r)),
    );
  }
}
