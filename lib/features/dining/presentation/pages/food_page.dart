import 'package:flutter/material.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

class FoodPage extends StatefulWidget {
  static route(Food food) => MaterialPageRoute(
        builder: (context) => FoodPage(food: food),
      );

  final Food food;
  const FoodPage({
    super.key,
    required this.food,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  Food get food => widget.food;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "UMD Dining",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                size: 24,
                weight: 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 30),
          NutritionText(text: 'Dining Halls: ${food.diningHalls.toString()}'),
          NutritionText(text: 'Section: ${food.sections.toString()}'),
          NutritionText(text: 'Served during: ${food.mealTypes.toString()}'),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              'Nutrition',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NutritionText(text: 'Calories per serving: ${food.caloriesPerServing} calories'),
          NutritionText(text: 'Serving size: ${food.servingSize}'),
          NutritionText(text: 'Protein: ${food.protein}'),
          NutritionText(text: 'Carbohydrates: ${food.totalCarbohydrates}'),
          NutritionText(text: 'Total Fats: ${food.totalFat}'),
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: NutritionText(text: 'Trans Fats: ${food.transFat}'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: NutritionText(text: 'Saturated Fats: ${food.saturatedFat}'),
          ),
          NutritionText(text: 'Cholesterol: ${food.cholesterol}'),
          NutritionText(text: 'Sodium: ${food.sodium}'),
          NutritionText(text: 'Dietary Fibers: ${food.dietaryFiber}'),
          NutritionText(text: 'Total Sugars: ${food.totalSugars}'),
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: NutritionText(text: 'Added Sugars: ${food.addedSugars}'),
          ),
          NutritionText(text: 'Allergens: ${food.allergens.toString()}'),
          NutritionText(text: 'Dates Served: ${food.dates.toString()}'),
        ],
      ),
    );
  }
}

class NutritionText extends StatelessWidget {
  const NutritionText({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
