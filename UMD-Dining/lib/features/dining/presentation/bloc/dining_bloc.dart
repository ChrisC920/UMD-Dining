import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_all_food_items.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food_details.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_food_query.dart';
import 'package:umd_dining_refactor/features/dining/domain/usecases/get_foods_by_query.dart';
part 'dining_event.dart';
part 'dining_state.dart';

class DiningBloc extends Bloc<DiningEvent, DiningState> {
  final GetAllFoods _getAllFoods;
  final GetFood _getFood;
  final GetFoodQuery _getFoodQuery;
  final GetFoodDetails _getFoodDetails;
  final GetFoodsByFilters _getFoodsByFilters;

  DiningBloc({
    required GetAllFoods getAllFoods,
    required GetFood getFood,
    required GetFoodQuery getFoodQuery,
    required GetFoodDetails getFoodDetails,
    required GetFoodsByFilters getFoodsByFilters,
  })  : _getAllFoods = getAllFoods,
        _getFood = getFood,
        _getFoodQuery = getFoodQuery,
        _getFoodDetails = getFoodDetails,
        _getFoodsByFilters = getFoodsByFilters,
        super(DiningInitial()) {
    on<DiningEvent>((event, emit) => emit(DiningLoading()));
    on<DiningFetchAllFoods>(_onFetchAllFoods);
    on<DiningFetchFood>(_onFetchFood);
    on<DiningFetchFoodQuery>(_onFetchFoodQuery);
    on<FoodFetchFoodDetails>(_onFetchFoodDetails);
    on<FoodFetchFoodsByFilters>(_onFetchFoodsByFilters);
  }

  void _onFetchFoodsByFilters(
    FoodFetchFoodsByFilters event,
    Emitter<DiningState> emit,
  ) async {
    // Emit loading state
    emit(DiningLoading());

    final res = await _getFoodsByFilters(GetFoodsByFiltersParams(
      dates: event.dates,
      diningHalls: event.diningHalls,
      mealTypes: event.mealTypes,
      sections: event.sections,
      allergens: event.allergens,
    ));

    res.fold(
      (l) {
        emit(DiningFailure(l.message));
      },
      (r) {
        emit(FoodGetFoodsByFiltersSuccess(r));
      },
    );
  }

  void _onFetchFoodDetails(
    FoodFetchFoodDetails event,
    Emitter<DiningState> emit,
  ) async {
    final res = await _getFoodDetails(GetFoodDetailsParams(foodId: event.foodId));

    res.fold(
      (l) => emit(DiningFailure(l.message)),
      (r) => emit(FoodGetFoodSuccess(r)),
    );
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
