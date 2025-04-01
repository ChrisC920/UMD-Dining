class Food {
  final int id;
  final String name;
  final String link;
  final String servingSize;
  final String servingsPerContainer;
  final int caloriesPerServing;
  final double totalFat;
  final double saturatedFat;
  final double transFat;
  final double totalCarbohydrates;
  final double dietaryFiber;
  final double totalSugars;
  final double addedSugars;
  final double cholesterol;
  final double sodium;
  final double protein;
  final List<String> allergens;
  final List<String> mealTypes;
  final List<String> diningHalls;
  final List<String> sections;

  Food({
    required this.id,
    required this.name,
    required this.link,
    required this.servingSize,
    required this.servingsPerContainer,
    required this.caloriesPerServing,
    required this.totalFat,
    required this.saturatedFat,
    required this.transFat,
    required this.totalCarbohydrates,
    required this.dietaryFiber,
    required this.totalSugars,
    required this.addedSugars,
    required this.cholesterol,
    required this.sodium,
    required this.protein,
    required this.allergens,
    required this.mealTypes,
    required this.diningHalls,
    required this.sections,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      link: json['link'],
      servingSize: json['serving_size'],
      servingsPerContainer: json['servings_per_container'],
      caloriesPerServing: json['calories_per_serving'],
      totalFat: json['total_fat'],
      saturatedFat: json['saturated_fat'],
      transFat: json['trans_fat'],
      totalCarbohydrates: json['total_carbohydrates'],
      dietaryFiber: json['dietary_fiber'],
      totalSugars: json['total_sugars'],
      addedSugars: json['added_sugars'],
      cholesterol: json['cholesterol'],
      sodium: json['sodium'],
      protein: json['protein'],
      allergens: (json['food_allergens'] as List?)?.map((e) => e['allergens']['name'] as String).toList() ?? [],
      mealTypes: (json['food_meal_types'] as List?)?.map((e) => e['meal_types']['name'] as String).toList() ?? [],
      diningHalls: (json['food_dining_halls'] as List?)?.map((e) => e['dining_halls']['name'] as String).toList() ?? [],
      sections: (json['food_sections'] as List?)?.map((e) => e['sections']['name'] as String).toList() ?? [],
    );
  }
}
