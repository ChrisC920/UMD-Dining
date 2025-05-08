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

final class FoodGetFoodSuccess extends DiningState {
  final List<Food> foods;
  FoodGetFoodSuccess(this.foods);
}

final class FoodGetFoodsByFiltersSuccess extends DiningState {
  final List<Food> foods;
  FoodGetFoodsByFiltersSuccess(this.foods);
}

final class AddFavoriteFoodSuccess extends DiningState {
  final int foodId;
  AddFavoriteFoodSuccess(this.foodId);
}

final class DeleteFavoriteFoodSuccess extends DiningState {
  final int foodId;
  DeleteFavoriteFoodSuccess(this.foodId);
}

final class FetchFavoriteFoodsSuccess extends DiningState {
  final List<Food> foods;
  FetchFavoriteFoodsSuccess(this.foods);
}
