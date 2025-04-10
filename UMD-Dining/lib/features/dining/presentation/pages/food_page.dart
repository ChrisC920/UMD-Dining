import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';

class FoodPage extends StatefulWidget {
  static route(Food food, List<Food> favoriteFoods, List<String> currDiningHall) => MaterialPageRoute(
        builder: (context) => FoodPage(
          food: food,
          favoriteFoods: favoriteFoods,
          currDiningHall: currDiningHall,
        ),
      );

  final Food food;
  final List<Food> favoriteFoods;
  final List<String> currDiningHall;

  const FoodPage({
    super.key,
    required this.food,
    required this.favoriteFoods,
    required this.currDiningHall,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<String> get currDiningHall => widget.currDiningHall;
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
          Row(
            children: [
              Text(
                food.name,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
                width: 2,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ],
          ),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 8),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     const Text(
          //       "Dining halls: ",
          //       style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     Flexible(
          //       child: Text(
          //         food.diningHalls.join(", "),
          //         style: const TextStyle(fontSize: 20),
          //         softWrap: true,
          //         overflow: TextOverflow.visible,
          //       ),
          //     ),
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text(
          //       "Sections:",
          //       style: TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     Text(
          //       food.sections.join(", "),
          //       style: const TextStyle(
          //         fontSize: 20,
          //       ),
          //     ),
          //   ],
          // ),
          // RichText(
          //   text: TextSpan(
          //     style: const TextStyle(fontFamily: 'Helvetica', fontSize: 20),

          //     children: [
          //       const TextSpan(text: "Dining halls: "),
          //       TextSpan(
          //         text: food.diningHalls.join(", "),
          //       ),
          //     ],
          //   ),
          // ),

          // NutritionText(text: 'Sections: ${food.sections.join(", ")}'),
          // NutritionText(text: 'Meal Types: ${food.mealTypes.join(", ")}'),
          // const SizedBox(height: 20),
          // const Text('Nutrition', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          // NutritionText(text: 'Calories: ${food.caloriesPerServing}'),
          // NutritionText(text: 'Serving size: ${food.servingSize}'),
          // NutritionText(text: 'Protein: ${food.protein}'),
          // NutritionText(text: 'Carbs: ${food.totalCarbohydrates}'),
          // NutritionText(text: 'Fats: ${food.totalFat}'),
          // NutritionText(text: 'Cholesterol: ${food.cholesterol}'),
          // NutritionText(text: 'Sodium: ${food.sodium}'),
          // NutritionText(text: 'Fiber: ${food.dietaryFiber}'),
          // NutritionText(text: 'Sugars: ${food.totalSugars}'),
          // NutritionText(text: 'Added Sugars: ${food.addedSugars}'),
          // NutritionText(text: 'Allergens: ${food.allergens.join(", ")}'),
          // NutritionText(text: 'Dates: ${food.dates.join(", ")}'),
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
