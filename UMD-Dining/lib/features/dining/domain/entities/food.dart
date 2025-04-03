class Food {
  final int id;
  final String name;
  final String link;
  final String servingSize;
  final String servingsPerContainer;
  final String caloriesPerServing;
  final String totalFat;
  final String saturatedFat;
  final String transFat;
  final String totalCarbohydrates;
  final String dietaryFiber;
  final String totalSugars;
  final String addedSugars;
  final String cholesterol;
  final String sodium;
  final String protein;
  final List<String> allergens;
  final List<String> mealTypes;
  final List<String> diningHalls;
  final List<String> sections;
  final List<String> dates;

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
    required this.mealTypes,
    required this.diningHalls,
    required this.sections,
    required this.allergens,
    required this.dates,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    // print("look here $json");
    return Food(
      id: json['food_id'] ?? 0,
      name: json['foods']?['name'] ?? "Unknown",
      link: json['foods']?['link'] ?? "No URL Found",
      servingSize: json['foods']?['serving_size'] ?? "N/A",
      servingsPerContainer: json['foods']?['servings_per_container'] ?? "N/A",
      caloriesPerServing: json['foods']?['calories_per_serving'] ?? "N/A",
      totalFat: (json['foods']?['total_fat'] ?? "N/A"),
      saturatedFat: (json['foods']?['saturated_fat'] ?? "N/A"),
      transFat: (json['foods']?['trans_fat'] ?? "N/A"),
      totalCarbohydrates: (json['foods']?['total_carbohydrates'] ?? "N/A"),
      dietaryFiber: (json['foods']?['dietary_fiber'] ?? "N/A"),
      totalSugars: (json['foods']?['total_sugars'] ?? "N/A"),
      addedSugars: (json['foods']?['added_sugars'] ?? "N/A"),
      cholesterol: (json['foods']?['cholesterol'] ?? "N/A"),
      sodium: (json['foods']?['sodium'] ?? "N/A"),
      protein: (json['foods']?['protein'] ?? "N/A"),

      // ✅ Fix: Directly extract name from objects instead of using a list
      diningHalls:
          json['food_dining_halls'] != null ? List<String>.from((json['food_dining_halls'] as List).map((e) => e['dining_halls']['name'] ?? "Unknown")) : [],
      mealTypes: json['food_meal_types'] != null ? List<String>.from((json['food_meal_types'] as List).map((e) => e['meal_types']['name'] ?? "Unknown")) : [],
      sections: json['food_sections'] != null ? List<String>.from((json['food_sections'] as List).map((e) => e['sections']['name'] ?? "Unknown")) : [],
      allergens: json['food_allergens'] != null ? List<String>.from((json['food_allergens'] as List).map((e) => e['allergens']['name'] ?? "Unknown")) : [],
      dates: [json['date_served'] ?? "0000-00-00"],
    );
  }
}
