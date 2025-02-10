class Dining {
  final int id;
  final DateTime createdAt;
  final String name;
  final List<String> diningHall;
  final List<String> section;
  final List<String> mealType;
  final String link;
  final String servingSize;
  final String servingsPerContainer;
  final String caloriesPerServing;
  final String totalFat;
  final String saturatedFat;
  final String transFat;
  final String cholesterol;
  final String sodium;
  final String totalCarbohydrates;
  final String dietaryFiber;
  final String totalSugar;
  final String addedSugar;
  final String protein;
  final List<String> allergens;

  Dining({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.diningHall,
    required this.section,
    required this.mealType,
    required this.link,
    required this.servingSize,
    required this.servingsPerContainer,
    required this.caloriesPerServing,
    required this.totalFat,
    required this.saturatedFat,
    required this.transFat,
    required this.cholesterol,
    required this.sodium,
    required this.totalCarbohydrates,
    required this.dietaryFiber,
    required this.totalSugar,
    required this.addedSugar,
    required this.protein,
    required this.allergens,
  });
}
