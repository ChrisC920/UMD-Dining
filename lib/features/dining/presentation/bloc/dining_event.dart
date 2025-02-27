part of 'dining_bloc.dart';

@immutable
sealed class DiningEvent {}

final class DiningFetchAllFoods extends DiningEvent {}

final class DiningFetchFood extends DiningEvent {
  final String name;

  DiningFetchFood({
    required this.name,
  });
}

final class DiningFetchFoodQuery extends DiningEvent {
  final int? id;
  final DateTime? createdAt;
  final String? name;
  final List<String>? diningHall;
  final List<String>? section;
  final List<String>? mealType;
  final String? link;
  final String? servingSize;
  final String? servingsPerContainer;
  final String? caloriesPerServing;
  final String? totalFat;
  final String? saturatedFat;
  final String? transFat;
  final String? cholesterol;
  final String? sodium;
  final String? totalCarbohydrates;
  final String? dietaryFiber;
  final String? totalSugar;
  final String? addedSugar;
  final String? protein;
  final List<String>? allergens;

  DiningFetchFoodQuery({
    this.id,
    this.createdAt,
    this.name,
    this.diningHall,
    this.section,
    this.mealType,
    this.link,
    this.servingSize,
    this.servingsPerContainer,
    this.caloriesPerServing,
    this.totalFat,
    this.saturatedFat,
    this.transFat,
    this.cholesterol,
    this.sodium,
    this.totalCarbohydrates,
    this.dietaryFiber,
    this.totalSugar,
    this.addedSugar,
    this.protein,
    this.allergens,
  });
}
