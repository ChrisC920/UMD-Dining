part of 'dining_bloc.dart';

@immutable
sealed class DiningState {}

final class DiningInitial extends DiningState {}

final class DiningLoading extends DiningState {}

final class FavoriteFoodsLoading extends DiningState {}

final class FavoriteFoodsFailure extends DiningState {
  final String error;
  FavoriteFoodsFailure(this.error);
}

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

final class FoodGetFoodsByFiltersSuccess extends DiningState {
  final List<Food> foods;
  FoodGetFoodsByFiltersSuccess(this.foods);
}

final class AddFavoriteFoodSuccess extends DiningState {}

final class DeleteFavoriteFoodSuccess extends DiningState {}

final class FetchFavoriteFoodsSuccess extends DiningState {
  final List<Food> foods;
  FetchFavoriteFoodsSuccess(this.foods);
}
