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
  late final List<String> allergens;
  late final List<String> mealTypes;
  late final List<String> diningHalls;
  late final List<String> sections;
  late final List<String> dates;

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
    //print("look here $json");
    final parsedFood = Food(
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
      diningHalls: json['foods']?['food_dining_halls'] != null
          ? List<String>.from((json['foods']?['food_dining_halls'] as List).map((e) => e['dining_halls']['name'] ?? "Unknown"))
          : [],
      mealTypes: json['foods']?['food_meal_types'] != null
          ? List<String>.from((json['foods']?['food_meal_types'] as List).map((e) => e['meal_types']['name'] ?? "Unknown"))
          : [],
      sections: json['foods']?['food_sections'] != null
          ? List<String>.from((json['foods']?['food_sections'] as List).map((e) => e['sections']['name'] ?? "Unknown"))
          : [],
      allergens: json['foods']?['food_allergens'] != null
          ? List<String>.from((json['foods']?['food_allergens'] as List).map((e) => e['allergens']['name'] ?? "Unknown"))
          : [],
      dates: json['foods']?['food_dates'] != null ? List<String>.from((json['foods']?['food_dates'] as List).map((e) => e['dates']['date'] ?? "Unknown")) : [],
    );
    // print("look here ${parsedFood.toString()}");
    return parsedFood;
  }

  factory Food.fromJsonAlt(Map<String, dynamic> json) {
    final parsedFood = Food(
      id: json['food_id'] ?? 0,
      name: json['food']?['name'] ?? "Unknown",
      link: json['food']?['link'] ?? "No URL Found",
      servingSize: json['food']?['serving_size'] ?? "N/A",
      servingsPerContainer: json['food']?['servings_per_container'] ?? "N/A",
      caloriesPerServing: json['food']?['calories_per_serving'] ?? "N/A",
      totalFat: (json['food']?['total_fat'] ?? "N/A"),
      saturatedFat: (json['food']?['saturated_fat'] ?? "N/A"),
      transFat: (json['food']?['trans_fat'] ?? "N/A"),
      totalCarbohydrates: (json['food']?['total_carbohydrates'] ?? "N/A"),
      dietaryFiber: (json['food']?['dietary_fiber'] ?? "N/A"),
      totalSugars: (json['food']?['total_sugars'] ?? "N/A"),
      addedSugars: (json['food']?['added_sugars'] ?? "N/A"),
      cholesterol: (json['food']?['cholesterol'] ?? "N/A"),
      sodium: (json['food']?['sodium'] ?? "N/A"),
      protein: (json['food']?['protein'] ?? "N/A"),
      diningHalls: [json['dining_hall']?['name']],
      mealTypes: [json['meal_type']?['name']],
      sections: [json['section']?['name']],
      allergens: json['food']?['food_allergens'] != null
          ? List<String>.from((json['food']?['food_allergens'] as List).map((e) => e['allergens']['name'] ?? "Unknown"))
          : [],
      dates: [(json['date']?['date']).toString()],
    );
    return parsedFood;
  }

  @override
  String toString() {
    return '''
Food {
  id: $id,
  name: $name,
  link: $link,
  servingSize: $servingSize,
  servingsPerContainer: $servingsPerContainer,
  caloriesPerServing: $caloriesPerServing,
  totalFat: $totalFat,
  saturatedFat: $saturatedFat,
  transFat: $transFat,
  totalCarbohydrates: $totalCarbohydrates,
  dietaryFiber: $dietaryFiber,
  totalSugars: $totalSugars,
  addedSugars: $addedSugars,
  cholesterol: $cholesterol,
  sodium: $sodium,
  protein: $protein,
  diningHalls: ${diningHalls.join(", ")},
  mealTypes: ${mealTypes.join(", ")},
  sections: ${sections.join(", ")},
  allergens: ${allergens.join(", ")},
  dates: ${dates.join(", ")}
}
''';
  }
}
