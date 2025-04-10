part of 'dining_bloc.dart';

@immutable
sealed class DiningEvent {}

final class FoodFetchFoodsByFilters extends DiningEvent {
  final List<String>? mealTypes;
  final List<String>? diningHalls;
  final List<String>? sections;
  final List<String>? dates;
  final List<String>? allergens;

  FoodFetchFoodsByFilters({
    this.mealTypes,
    this.diningHalls,
    this.sections,
    this.dates,
    this.allergens,
  });
}

final class FoodFetchFoodDetails extends DiningEvent {
  final int foodId;

  FoodFetchFoodDetails({
    required this.foodId,
  });
}

final class AddFavoriteFoodEvent extends DiningEvent {
  final int foodId;

  AddFavoriteFoodEvent({
    required this.foodId,
  });
}

final class DeleteFavoriteFoodEvent extends DiningEvent {
  final int foodId;

  DeleteFavoriteFoodEvent({
    required this.foodId,
  });
}

final class FetchFavoriteFoodsEvent extends DiningEvent {}
