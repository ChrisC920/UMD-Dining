part of 'dining_bloc.dart';

@immutable
sealed class DiningState {}

final class DiningInitial extends DiningState {}

final class DiningLoading extends DiningState {}

final class DiningFailure extends DiningState {
  final String error;
  DiningFailure(this.error);
}

final class DiningGetAllFoodsSuccess extends DiningState {
  final List<Dining> foods;
  DiningGetAllFoodsSuccess(this.foods);
}

final class DiningGetFoodSuccess extends DiningState {
  final Dining food;
  DiningGetFoodSuccess(this.food);
}

final class DiningGetFoodQuerySuccess extends DiningState {
  final List<Dining> foods;
  DiningGetFoodQuerySuccess(this.foods);
}

final class FoodGetFoodSuccess extends DiningState {
  final Food food;
  FoodGetFoodSuccess(this.food);
}
