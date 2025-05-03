import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/expansion_text.dart';

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

  String parseDiningHall(String diningHall) {
    switch (diningHall) {
      case "South":
        return "South Campus Dining Hall";
      case "Yahentamitsi":
        return "Yahentamitsi Dining Hall";
      case "251 North":
        return "251 North Dining Hall";
      default:
        return "N/A";
    }
  }

  String toProperCase(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String parseAllergen(String allergen) {
    allergen = toProperCase(allergen);
    switch (allergen) {
      case "Halalfriendly":
        return "Halal";
      default:
        return allergen;
    }
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
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
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
        },
        builder: (context, state) {
          if (state is DiningLoading) {
            return const Expanded(child: Center(child: CircularProgressIndicator()));
          }
          if (state is FoodGetFoodSuccess) {
            foods = state.foods;
            if (currDiningHall.length == 1) {
              foods = foods.where((food) => food.diningHalls.contains(currDiningHall.first)).toList();
              final mergedFoods = foods
                  .fold<Map<String, Food>>({}, (map, food) {
                    final key = '${food.name}|${food.dates.first}';

                    if (map.containsKey(key)) {
                      final existing = map[key]!;

                      map[key] = Food(
                        id: existing.id,
                        name: existing.name,
                        link: existing.link,
                        servingSize: existing.servingSize,
                        servingsPerContainer: existing.servingsPerContainer,
                        caloriesPerServing: existing.caloriesPerServing,
                        totalFat: existing.totalFat,
                        saturatedFat: existing.saturatedFat,
                        transFat: existing.transFat,
                        totalCarbohydrates: existing.totalCarbohydrates,
                        dietaryFiber: existing.dietaryFiber,
                        totalSugars: existing.totalSugars,
                        addedSugars: existing.addedSugars,
                        cholesterol: existing.cholesterol,
                        sodium: existing.sodium,
                        protein: existing.protein,
                        diningHalls: food.diningHalls,
                        mealTypes: {...existing.mealTypes, ...food.mealTypes}.toSet().toList(),
                        sections: {...existing.sections, ...food.sections}.toSet().toList(),
                        allergens: existing.allergens,
                        dates: existing.dates,
                      );
                    } else {
                      map[key] = food;
                    }

                    return map;
                  })
                  .values
                  .toList();
              foods = mergedFoods;
            }
            final food = foods.first;
            return ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                _foodInfoHeader(food),
                _nutritionFactsCard(food),
                _allergenCard(food),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Container _foodInfoHeader(Food food) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  food.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(parseDiningHall(food.diningHalls.first),
                  style: const TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 6),
              Text(food.caloriesPerServing,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              const Text(" cal",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(width: 2, height: 24, color: Colors.black12),
              ),
              const Icon(
                Icons.restaurant,
                color: Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                food.servingsPerContainer.split(' ').first,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                " serving(s)",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, // space between chips
            runSpacing: 8, // space between lines
            children: food.sections.map((section) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  section,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Container _allergenCard(Food food) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Allergens",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: food.allergens.where((allergen) => allergen != 'Smartchoice').map((allergen) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  parseAllergen(allergen),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Container _nutritionFactsCard(Food food) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nutrition Facts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          NutritionText(label: "Serving Size", value: food.servingSize),
          const SizedBox(height: 4),
          NutritionText(label: "Calories Per Serving", value: "${food.caloriesPerServing} cal"),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          NutritionText(label: "Protein", value: food.protein),
          const SizedBox(height: 4),
          NutritionText(label: "Carbohydrates", value: food.totalCarbohydrates),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: NutritionText(label: "Dietary Fiber", value: food.dietaryFiber),
          ),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.only(left: 24), child: NutritionText(label: "Total Sugars", value: food.totalSugars)),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.only(left: 24), child: NutritionText(label: "Added Sugars", value: food.addedSugars)),
          const SizedBox(height: 4),
          NutritionText(label: "Fats", value: food.totalFat),
          const SizedBox(height: 4),

          Padding(padding: const EdgeInsets.only(left: 24), child: NutritionText(label: "Saturated Fats", value: food.transFat)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: NutritionText(label: "Trans Fats", value: food.saturatedFat),
          ),
          const SizedBox(height: 4),
          // ExpandableTextRow(
          //   row: NutritionText(label: "Carbohydrates", value: food.totalCarbohydrates),
          //   dropdown: Column(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 24),
          //         child: NutritionText(label: "Dietary Fiber", value: food.dietaryFiber),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 24),
          //         child: NutritionText(label: "Total Sugars", value: food.totalSugars),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 24),
          //         child: NutritionText(label: "Added Sugars", value: food.addedSugars),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 4),
          // ExpandableTextRow(
          //   row: NutritionText(label: "Fats", value: food.totalFat),
          //   dropdown: Column(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 24.0),
          //         child: NutritionText(label: "Saturated Fats", value: food.saturatedFat),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 24),
          //         child: NutritionText(label: "Trans Fats", value: food.transFat),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          NutritionText(label: "Cholesterol", value: food.cholesterol),
          const SizedBox(height: 4),
          NutritionText(label: "Sodium", value: food.sodium),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class NutritionText extends StatelessWidget {
  const NutritionText({
    super.key,
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
