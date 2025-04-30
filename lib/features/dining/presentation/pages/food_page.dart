import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';

class FoodPage extends StatefulWidget {
  static route(
    int foodId,
    List<Food> favoriteFoods,
    List<String> currDiningHall,
    DateTime? date,
    Set<String> mealTypes,
  ) =>
      MaterialPageRoute(
        builder: (context) => FoodPage(
          foodId: foodId,
          favoriteFoods: favoriteFoods,
          currDiningHall: currDiningHall,
          date: date,
          mealTypes: mealTypes,
        ),
      );

  final int foodId;
  final List<Food> favoriteFoods;
  final List<String> currDiningHall;
  final DateTime? date;
  final Set<String> mealTypes;

  const FoodPage({
    super.key,
    required this.foodId,
    required this.favoriteFoods,
    required this.currDiningHall,
    this.date,
    required this.mealTypes,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<String> get currDiningHall => widget.currDiningHall;
  // Set<String> get mealTypes => widget.mealTypes;
  DateTime? get date => widget.date;
  late bool isFavorite;
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.favoriteFoods.any((f) => f.id == widget.foodId);
    context.read<DiningBloc>().add(FoodFetchFoodDetails(id: widget.foodId, date: date));
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      context.read<DiningBloc>().add(AddFavoriteFoodEvent(foodId: widget.foodId));
    } else {
      context.read<DiningBloc>().add(DeleteFavoriteFoodEvent(foodId: widget.foodId));
    }

    context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
  }

  String formatDate(String rawDate) {
    final DateTime date = DateTime.parse(rawDate);
    final DateFormat formatter = DateFormat('EEEE, MMMM d');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    // final food = widget.food;
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
      body: BlocConsumer<DiningBloc, DiningState>(
        listener: (context, state) {
          if (state is DiningFailure) {
            showSnackBar(context, state.error);
          }
          // if (state is FoodGetFoodSuccess) {
          //   print("working");
          //   print(state.foods);
          //   setState(() {
          //     foods = state.foods;
          //     food = foods[0];
          //   });
          // }
        },
        builder: (context, state) {
          if (state is DiningLoading) {
            return const Expanded(child: Center(child: CircularProgressIndicator()));
          }
          if (state is FoodGetFoodSuccess) {
            // print(currDiningHall.first);
            // for (final aFood in state.foods) {
            //   print(aFood);
            // }
            final food = state.foods.first;
            foods = state.foods;
            if (currDiningHall.length == 1) {
              foods = foods.where((food) => food.diningHalls.contains(currDiningHall.first)).toList();
            }
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        food.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[400]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Found At: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        food.sections.join(", "),
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Served During: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        food.mealTypes.join(", "),
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last Served: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        formatDate(food.dates.last),
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),

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
                // NutritionText(text: 'Dates: ${food.dates.join(", ")}'),*/
              ],
            );
          }
          return const SizedBox();
        },
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
