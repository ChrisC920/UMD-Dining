import 'package:flutter/material.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';

class FoodPage extends StatefulWidget {
  static route(Dining food) => MaterialPageRoute(
        builder: (context) => FoodPage(food: food),
      );

  final Dining food;
  const FoodPage({
    super.key,
    required this.food,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  Dining get food => widget.food;

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
          NutritionText(text: 'Dining Halls: ${food.diningHall.toString()}'),
          NutritionText(text: 'Section: ${food.section.toString()}'),
          NutritionText(text: 'Served during: ${food.mealType.toString()}'),
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
          NutritionText(
              text:
                  'Calories per serving: ${food.caloriesPerServing} calories'),
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
          NutritionText(text: 'Total Sugars: ${food.totalSugar}'),
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: NutritionText(text: 'Added Sugars: ${food.addedSugar}'),
          ),
          NutritionText(text: 'Allergens: ${food.allergens.toString()}'),
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
