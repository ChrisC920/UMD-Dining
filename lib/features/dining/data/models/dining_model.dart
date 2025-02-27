import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';

class DiningModel extends Dining {
  DiningModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.diningHall,
    required super.section,
    required super.mealType,
    required super.link,
    required super.servingSize,
    required super.servingsPerContainer,
    required super.caloriesPerServing,
    required super.totalFat,
    required super.saturatedFat,
    required super.transFat,
    required super.cholesterol,
    required super.sodium,
    required super.totalCarbohydrates,
    required super.dietaryFiber,
    required super.totalSugar,
    required super.addedSugar,
    required super.protein,
    required super.allergens,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'dining_hall': diningHall,
      'section': section,
      'meal_type': mealType,
      'link': link,
      'serving_size': servingSize,
      'servings_per_container': servingsPerContainer,
      'calories_per_serving': caloriesPerServing,
      'total_fat': totalFat,
      'saturated_fat': saturatedFat,
      'trans_fat': transFat,
      'cholesterol': cholesterol,
      'sodium': sodium,
      'total_carbohydrates': totalCarbohydrates,
      'dietary_fiber': dietaryFiber,
      'total_sugars': totalSugar,
      'added_sugars': addedSugar,
      'protein': protein,
      'allergens': allergens,
    };
  }

  factory DiningModel.fromJson(Map<String, dynamic> map) {
    return DiningModel(
      id: map['id'],
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
      name: map['name'] as String,
      diningHall: List<String>.from(map['dining_hall'] ?? []),
      section: List<String>.from(map['section'] ?? []),
      mealType: List<String>.from(map['meal_type'] ?? []),
      link: map['link'] as String,
      servingSize: map['serving_size'] as String,
      servingsPerContainer: map['servings_per_container'] as String,
      caloriesPerServing: map['calories_per_serving'] as String,
      totalFat: map['total_fat'] as String,
      saturatedFat: map['saturated_fat'] as String,
      transFat: map['trans_fat'] as String,
      cholesterol: map['cholesterol'] as String,
      sodium: map['sodium'] as String,
      totalCarbohydrates: map['total_carbohydrates'] as String,
      dietaryFiber: map['dietary_fiber'] as String,
      totalSugar: map['total_sugars'] as String,
      addedSugar: map['added_sugars'] as String,
      protein: map['protein'] as String,
      allergens: List<String>.from(map['allergens'] ?? []),
    );
  }

  DiningModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    List<String>? diningHall,
    List<String>? section,
    List<String>? mealType,
    String? link,
    String? servingSize,
    String? servingsPerContainer,
    String? caloriesPerServing,
    String? totalFat,
    String? saturatedFat,
    String? transFat,
    String? cholesterol,
    String? sodium,
    String? totalCarbohydrates,
    String? dietaryFiber,
    String? totalSugar,
    String? addedSugar,
    String? protein,
    List<String>? allergens,
  }) {
    return DiningModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      diningHall: diningHall ?? this.diningHall,
      section: section ?? this.section,
      mealType: mealType ?? this.mealType,
      link: link ?? this.link,
      servingSize: servingSize ?? this.servingSize,
      servingsPerContainer: servingsPerContainer ?? this.servingsPerContainer,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      totalFat: totalFat ?? this.totalFat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      transFat: transFat ?? this.transFat,
      cholesterol: cholesterol ?? this.cholesterol,
      sodium: sodium ?? this.sodium,
      totalCarbohydrates: totalCarbohydrates ?? this.totalCarbohydrates,
      dietaryFiber: dietaryFiber ?? this.dietaryFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      addedSugar: addedSugar ?? this.addedSugar,
      protein: protein ?? this.protein,
      allergens: allergens ?? this.allergens,
    );
  }
}
