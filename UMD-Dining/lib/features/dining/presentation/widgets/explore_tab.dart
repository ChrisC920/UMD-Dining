import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/food_page.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/filter_card.dart';

class ExploreTab extends StatefulWidget {
  final List<Food> allFoods;
  final Set<String> localFavoriteIds;
  final void Function(String foodId, bool isFav) onToggleFavorite;
  final List<String>? selectedHalls;
  final DateTime selectedDate;

  const ExploreTab({
    super.key,
    required this.allFoods,
    required this.localFavoriteIds,
    required this.onToggleFavorite,
    required this.selectedHalls,
    required this.selectedDate,
  });

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Food> _filteredFoods = [];
  Set<String> _selectedMealTypes = {};
  Set<String> _selectedAllergens = {};
  Set<String> _selectedDietaryPreferences = {};
  DateTime? _selectedDate;
  int _visibleCount = 30;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _searchController.addListener(_filterItems);
    _scrollController.addListener(_onScroll);
    _filteredFoods = widget.allFoods;
  }

  @override
  void didUpdateWidget(ExploreTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allFoods != widget.allFoods) {
      _filterItems();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_visibleCount < _filteredFoods.length) {
        setState(() => _visibleCount += 20);
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _visibleCount = 30;
      _filteredFoods = widget.allFoods.where((food) {
        final allergenLabels = food.allergens.map(_convertAllergen).toList();
        final matchesFilters =
            _selectedMealTypes.every((t) => food.mealTypes.contains(t)) &&
            _selectedDietaryPreferences.every((p) => allergenLabels.contains(p)) &&
            _selectedAllergens.every((a) => !allergenLabels.contains(a));

        if (query.isEmpty) return matchesFilters;

        final name = food.name.toLowerCase();
        final similarity = StringSimilarity.compareTwoStrings(name, query);
        return (name.contains(query) || similarity > 0.4) && matchesFilters;
      }).toList();

      if (query.isNotEmpty) {
        _filteredFoods.sort((a, b) {
          final simA = StringSimilarity.compareTwoStrings(a.name.toLowerCase(), query);
          final simB = StringSimilarity.compareTwoStrings(b.name.toLowerCase(), query);
          return simB.compareTo(simA);
        });
      }
    });
  }

  String _convertAllergen(String allergen) {
    switch (allergen) {
      case 'Contains sesame': return 'Sesame';
      case 'vegan': return 'Vegan';
      case 'Contains fish': return 'Fish';
      case 'Contains nuts': return 'Nuts';
      case 'Contains Shellfish': return 'Shellfish';
      case 'Contains dairy': return 'Dairy';
      case 'smartchoice': return 'Smart Choice';
      case 'HalalFriendly': return 'Halal';
      case 'Contains egg': return 'Eggs';
      case 'Contains soy': return 'Soy';
      case 'Contains gluten': return 'Gluten';
      case 'vegetarian': return 'Vegetarian';
      default: return allergen;
    }
  }

  List<String> get _activeFilterLabels {
    final labels = <String>[];
    for (final t in _selectedMealTypes) labels.add('Meal: $t');
    for (final p in _selectedDietaryPreferences) labels.add('Diet: $p');
    for (final a in _selectedAllergens) labels.add('No: $a');
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredFoods.take(_visibleCount).toList();
    final activeFilters = _activeFilterLabels;

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search foods...',
              backgroundColor: const WidgetStatePropertyAll(Color(0xFFF5F5F5)),
              elevation: const WidgetStatePropertyAll(0),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
              leading: const Icon(Icons.search, color: Colors.grey),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => FilterCard(
                        selectedAllergens: _selectedAllergens,
                        selectedMealTypes: _selectedMealTypes,
                        selectedDietaryPreferences: _selectedDietaryPreferences,
                        selectedDate: _selectedDate,
                        onApply: (allergens, meals, dietary, date) {
                          final dateChanged = date != _selectedDate;
                          setState(() {
                            _selectedAllergens = allergens;
                            _selectedMealTypes = meals;
                            _selectedDietaryPreferences = dietary;
                            _selectedDate = date;
                          });
                          if (dateChanged && date != null) {
                            context.read<DiningBloc>().add(FoodFetchFoodsByFilters(
                                  diningHalls: widget.selectedHalls,
                                  date: date,
                                ));
                          }
                          _filterItems();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Active filter chips
          if (activeFilters.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: activeFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final label = activeFilters[i];
                  return Chip(
                    label: Text(label, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        if (label.startsWith('Meal: ')) {
                          _selectedMealTypes.remove(label.substring(6));
                        } else if (label.startsWith('Diet: ')) {
                          _selectedDietaryPreferences.remove(label.substring(6));
                        } else if (label.startsWith('No: ')) {
                          _selectedAllergens.remove(label.substring(4));
                        }
                      });
                      _filterItems();
                    },
                    backgroundColor: AppPallete.mainRed.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),

          // Sort bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${_filteredFoods.length} items',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Food list
          Expanded(
            child: widget.allFoods.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredFoods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No foods found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, i) => _FoodListTile(
                          food: displayed[i],
                          isFavorite: widget.localFavoriteIds.contains(displayed[i].id),
                          onToggleFavorite: () => widget.onToggleFavorite(
                            displayed[i].id,
                            widget.localFavoriteIds.contains(displayed[i].id),
                          ),
                          onTap: () {
                            final clerkId = ClerkAuth.of(context).client.activeSession?.user.id ?? '';
                            context.read<DiningBloc>().add(FetchFavoriteFoodsEvent(clerkId: clerkId));
                            Navigator.push(
                              context,
                              FoodPage.route(
                                displayed[i].id,
                                widget.allFoods,
                                widget.selectedHalls ?? [],
                                _selectedDate,
                                displayed[i].mealTypes.toSet(),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FoodListTile extends StatelessWidget {
  final Food food;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _FoodListTile({
    required this.food,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  String _extractNum(String value) {
    return value.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  Color _calColor(int cal) {
    if (cal < 300) return Colors.green.shade600;
    if (cal < 600) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final cal = int.tryParse(food.caloriesPerServing) ?? 0;
    final protein = _extractNum(food.protein);
    final carbs = _extractNum(food.totalCarbohydrates);
    final fat = _extractNum(food.totalFat);
    final proteinVal = double.tryParse(protein) ?? 0;
    final carbsVal = double.tryParse(carbs) ?? 0;
    final fatVal = double.tryParse(fat) ?? 0;
    final total = proteinVal + carbsVal + fatVal;

    final badges = <String>[];
    final allergens = food.allergens.map((a) => a.toLowerCase()).toList();
    if (allergens.contains('vegan')) badges.add('Vegan');
    else if (allergens.contains('vegetarian')) badges.add('Veggie');
    if (allergens.any((a) => a.contains('halal'))) badges.add('Halal');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppPallete.mainRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant, color: AppPallete.mainRed, size: 22),
            ),
            const SizedBox(width: 12),

            // Name + section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (food.sections.isNotEmpty)
                    Text(
                      food.sections.first,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  if (badges.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: badges.map((b) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(b, style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right side: calories + macros + fav
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _calColor(cal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cal > 0 ? '$cal cal' : '-- cal',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                // MacroBar
                if (total > 0)
                  SizedBox(
                    width: 80,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Row(
                        children: [
                          Flexible(
                            flex: (proteinVal * 100 / total).round(),
                            child: Container(color: Colors.blue.shade400),
                          ),
                          Flexible(
                            flex: (carbsVal * 100 / total).round(),
                            child: Container(color: Colors.orange.shade400),
                          ),
                          Flexible(
                            flex: (fatVal * 100 / total).round(),
                            child: Container(color: Colors.purple.shade300),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
