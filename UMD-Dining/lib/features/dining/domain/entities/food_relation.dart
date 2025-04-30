import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

class FoodRelation {
  final Food food;
  final String diningHall;
  final String mealType;
  final String section;
  final String date;

  FoodRelation({
    required this.food,
    required this.diningHall,
    required this.mealType,
    required this.section,
    required this.date,
  });
}
