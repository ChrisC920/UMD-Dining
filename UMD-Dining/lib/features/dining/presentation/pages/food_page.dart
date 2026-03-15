import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';

class FoodPage extends StatefulWidget {
  static route(
    String foodId,
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

  final String foodId;
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
  DateTime? get date => widget.date;
  late bool isFavorite;
  Food? displayedFood;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.favoriteFoods.any((f) => f.id == widget.foodId);
    context.read<DiningBloc>().add(FoodFetchFoodDetails(id: widget.foodId, date: date));
  }

  String _parseDiningHall(String diningHall) {
    switch (diningHall) {
      case "South":
        return "South Campus";
      case "Yahentamitsi":
        return "Yahentamitsi";
      case "251 North":
        return "251 North";
      default:
        return diningHall;
    }
  }

  String _parseAllergen(String allergen) {
    switch (allergen.toLowerCase()) {
      case "halalfriendly":
        return "Halal";
      case "smartchoice":
        return "Smart Choice";
      case "vegan":
        return "Vegan";
      case "vegetarian":
        return "Vegetarian";
      default:
        // Remove "Contains " prefix for display
        if (allergen.toLowerCase().startsWith('contains ')) {
          final word = allergen.substring(9);
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return allergen[0].toUpperCase() + allergen.substring(1).toLowerCase();
    }
  }

  void _toggleFavorite() {
    final clerkId = ClerkAuth.of(context).client.activeSession?.user.id ?? '';
    setState(() => isFavorite = !isFavorite);
    if (isFavorite) {
      context.read<DiningBloc>().add(AddFavoriteFoodEvent(clerkId: clerkId, foodId: widget.foodId));
    } else {
      context.read<DiningBloc>().add(DeleteFavoriteFoodEvent(clerkId: clerkId, foodId: widget.foodId));
    }
    context.read<DiningBloc>().add(FetchFavoriteFoodsEvent(clerkId: clerkId));
  }

  double _parseNum(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  // Returns allergen semantic color
  Color _allergenColor(String allergen) {
    final lower = allergen.toLowerCase();
    if (lower == 'vegan' || lower == 'vegetarian') return Colors.green.shade600;
    if (lower.contains('halal')) return Colors.amber.shade700;
    if (lower == 'smartchoice') return Colors.teal.shade600;
    return Colors.red.shade400;
  }

  IconData _allergenIcon(String allergen) {
    final lower = allergen.toLowerCase();
    if (lower == 'vegan' || lower == 'vegetarian') return Icons.eco;
    if (lower.contains('halal')) return Icons.star_rounded;
    if (lower == 'smartchoice') return Icons.check_circle_outline;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocConsumer<DiningBloc, DiningState>(
        listener: (context, state) {
          if (state is DiningFailure) showSnackBar(context, state.error);
          if (state is FoodGetFoodSuccess) {
            var fetchedFoods = state.foods;

            if (currDiningHall.length == 1) {
              fetchedFoods = fetchedFoods
                  .where((f) => f.diningHalls.contains(currDiningHall.first))
                  .toList();

              final merged = fetchedFoods
                  .fold<Map<String, Food>>({}, (map, food) {
                    final key = '${food.name}|${food.dates.isNotEmpty ? food.dates.first : ""}';
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
                        mealTypes: {...existing.mealTypes, ...food.mealTypes}.toList(),
                        sections: {...existing.sections, ...food.sections}.toList(),
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
              fetchedFoods = merged;
            }

            if (fetchedFoods.isNotEmpty) {
              setState(() => displayedFood = fetchedFoods.first);
            }
          }
        },
        builder: (context, state) {
          if (displayedFood == null) {
            return CustomScrollView(
              slivers: [
                _sliverAppBar(null),
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }
          return CustomScrollView(
            slivers: [
              _sliverAppBar(displayedFood),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _headerCard(displayedFood!),
                    _nutritionCard(displayedFood!),
                    _allergenCard(displayedFood!),
                    if (displayedFood!.diningHalls.length > 1) _alsoAtCard(displayedFood!),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _sliverAppBar(Food? food) {
    final hallImage = food != null
        ? AppPallete.hallImage(food.diningHalls.isNotEmpty ? [food.diningHalls.first] : null)
        : 'assets/images/random_food.jpg';

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppPallete.mainRed,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: food != null
            ? Text(
                food.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(hallImage, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(Food food) {
    final protein = _parseNum(food.protein);
    final carbs = _parseNum(food.totalCarbohydrates);
    final fat = _parseNum(food.totalFat);
    final total = protein + carbs + fat;
    final cal = (int.tryParse(food.caloriesPerServing) ?? 0) *
        (int.tryParse(food.servingsPerContainer.split(' ').first) ?? 1);

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: food info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                if (food.diningHalls.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppPallete.mainRed),
                      const SizedBox(width: 4),
                      Text(
                        _parseDiningHall(food.diningHalls.first),
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$cal cal',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.restaurant, size: 16, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${food.servingsPerContainer.split(' ').first} serving(s)',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (food.sections.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: food.sections.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                    )).toList(),
                  ),
              ],
            ),
          ),

          // Right: macro donut chart
          if (total > 0)
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                          sections: [
                            PieChartSectionData(
                              value: protein,
                              color: Colors.blue.shade400,
                              radius: 16,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: carbs,
                              color: Colors.orange.shade400,
                              radius: 16,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: fat,
                              color: Colors.purple.shade300,
                              radius: 16,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${food.caloriesPerServing}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'cal',
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _macroDot(Colors.blue.shade400, 'P'),
                    const SizedBox(width: 4),
                    _macroDot(Colors.orange.shade400, 'C'),
                    const SizedBox(width: 4),
                    _macroDot(Colors.purple.shade300, 'F'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _macroDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _nutritionCard(Food food) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FDA-style header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Facts',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const Divider(thickness: 8, color: Colors.black),
                _nutritionRow('Serving Size', food.servingSize, bold: true),
                const Divider(thickness: 4, color: Colors.black),
                _nutritionRow('Calories', food.caloriesPerServing, bold: true, large: true),
                const Divider(thickness: 1, color: Colors.black),
                _nutritionRow('Total Fat', food.totalFat, bold: true),
                _nutritionSubRow('Saturated Fat', food.saturatedFat),
                _nutritionSubRow('Trans Fat', food.transFat),
                _nutritionRow('Total Carbohydrates', food.totalCarbohydrates, bold: true),
                _nutritionSubRow('Dietary Fiber', food.dietaryFiber),
                _nutritionSubRow('Total Sugars', food.totalSugars),
                _nutritionSubRow('Added Sugars', food.addedSugars),
                _nutritionRow('Protein', food.protein, bold: true),
                const Divider(thickness: 4, color: Colors.black),
                _nutritionRow('Cholesterol', food.cholesterol),
                _nutritionRow('Sodium', food.sodium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value, {bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionSubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _allergenCard(Food food) {
    final visibleAllergens = food.allergens
        .where((a) => a.toLowerCase() != 'smartchoice')
        .toList();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allergens & Labels',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...visibleAllergens.map((allergen) {
                final color = _allergenColor(allergen);
                final icon = _allergenIcon(allergen);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        _parseAllergen(allergen),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Smart Choice badge separately
              if (food.allergens.any((a) => a.toLowerCase() == 'smartchoice'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 14, color: Colors.teal.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Smart Choice',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alsoAtCard(Food food) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Also Available At',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: food.diningHalls.map((hall) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppPallete.mainRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppPallete.mainRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppPallete.mainRed),
                  const SizedBox(width: 4),
                  Text(
                    _parseDiningHall(hall),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppPallete.mainRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
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
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
