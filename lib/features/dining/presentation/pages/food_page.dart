import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';

class FoodPage extends StatefulWidget {
  static route(Food food, List<Food> favoriteFoods) => MaterialPageRoute(
        builder: (context) => FoodPage(
          food: food,
          favoriteFoods: favoriteFoods,
        ),
      );

  final Food food;
  final List<Food> favoriteFoods; // 👈 New

  const FoodPage({
    super.key,
    required this.food,
    required this.favoriteFoods,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.favoriteFoods.any((f) => f.id == widget.food.id);
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      context.read<DiningBloc>().add(AddFavoriteFoodEvent(foodId: widget.food.id));
    } else {
      context.read<DiningBloc>().add(DeleteFavoriteFoodEvent(foodId: widget.food.id));
    }

    // Optionally refresh global favorites state
    context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "UMD Dining",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Helvetica',
          ),
        ),
        elevation: 1.0,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 24,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(food.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 0),
          Text(food.diningHalls.join(", "),
              style: const TextStyle(
                color: Color.fromARGB(255, 178, 178, 178),
                fontSize: 16,
              )),
          NutritionText(text: 'Sections: ${food.sections.join(", ")}'),
          NutritionText(text: 'Meal Types: ${food.mealTypes.join(", ")}'),
          const SizedBox(height: 20),
          const Text('Nutrition', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          NutritionText(text: 'Calories: ${food.caloriesPerServing}'),
          NutritionText(text: 'Serving size: ${food.servingSize}'),
          NutritionText(text: 'Protein: ${food.protein}'),
          NutritionText(text: 'Carbs: ${food.totalCarbohydrates}'),
          NutritionText(text: 'Fats: ${food.totalFat}'),
          NutritionText(text: 'Cholesterol: ${food.cholesterol}'),
          NutritionText(text: 'Sodium: ${food.sodium}'),
          NutritionText(text: 'Fiber: ${food.dietaryFiber}'),
          NutritionText(text: 'Sugars: ${food.totalSugars}'),
          NutritionText(text: 'Added Sugars: ${food.addedSugars}'),
          NutritionText(text: 'Allergens: ${food.allergens.join(", ")}'),
          NutritionText(text: 'Dates: ${food.dates.join(", ")}'),
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
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }
}
