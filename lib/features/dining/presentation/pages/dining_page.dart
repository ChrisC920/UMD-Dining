import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/food_page.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/filter_card.dart';

class DiningPage extends StatefulWidget {
  static route(List<String>? diningHall) => MaterialPageRoute(
        builder: (context) => DiningPage(diningHall: diningHall),
      );

  final List<String>? diningHall;
  const DiningPage({
    super.key,
    this.diningHall,
  });

  @override
  State<DiningPage> createState() => _DiningPageState();
}

class _DiningPageState extends State<DiningPage> {
  List<String>? get diningHall => widget.diningHall;
  final TextEditingController _searchController = TextEditingController();
  List<Food> allItems = [];
  List<Food> items = [];
  List<Food> searchHistory = [];
  List<Food> favoriteFoods = [];
  Set<String> selectedMealTypes = <String>{};
  Set<String> selectedAllergens = <String>{};
  Set<String> selectedDietaryPreferences = <String>{};
  int currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    if (currentPageIndex == 1) {
      context.read<DiningBloc>().add(FoodFetchFoodsByFilters(
            diningHalls: diningHall,
          ));
    } else if (currentPageIndex == 2) {
      context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
    }
    setState(() {
      currentPageIndex = 1;
    });
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
  }

  void search(String query, List<String> mealTypes) {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        items = allItems; // Show all items when search is empty
      } else {
        items =
            items.where((food) => food.name.toLowerCase().contains(query)).where((food) => mealTypes.every((type) => food.mealTypes.contains(type))).toList();
      }
    });
  }

  Timer? _debounce;

  void _filterItems() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        items = allItems
            .where((food) =>
                food.name.toLowerCase().contains(query) &&
                selectedMealTypes.every((type) => food.mealTypes.contains(type)) &&
                selectedDietaryPreferences.every((pref) => convertAllergenList(food.allergens).contains(pref)) &&
                selectedAllergens.every((allergen) => !convertAllergenList(food.allergens).contains(allergen)))
            .toList();
      });
    });
  }

  // void _filterItems() {
  //   final query = _searchController.text.toLowerCase();

  //   setState(() {
  //     items = allItems.where((food) {
  //       print(food.allergens);
  //       // ✅ Text search match
  //       final matchesQuery = food.name.toLowerCase().contains(query);

  //       // ✅ Meal types: All selected meal types must be in food's mealTypes
  //       final matchesMealTypes = selectedMealTypes.every((type) => food.mealTypes.contains(type));

  //       // ✅ Allergens: food must NOT contain any selected allergen
  //       final excludesAllergens = selectedAllergens.every((allergen) => !convertAllergenList(food.allergens).contains(allergen));

  //       // ✅ Dietary preferences: each selected preference must match
  //       final matchesDietPrefs = selectedDietaryPreferences.every((pref) => convertAllergenList(food.allergens).contains(pref));

  //       return matchesQuery && matchesMealTypes && excludesAllergens && matchesDietPrefs;
  //     }).toList();
  //   });
  // }

  List<String> convertAllergenList(List<String> allergens) {
    return allergens.map((e) => convertAllergen(e)).toList();
  }

  String convertAllergen(String allergen) {
    switch (allergen) {
      case 'Contains sesame':
        return 'Sesame';
      case 'vegan':
        return 'Vegan';
      case 'Contains fish':
        return 'Fish';
      case 'Contains nuts':
        return 'Nuts';
      case 'Contains Shellfish':
        return 'Shellfish';
      case 'Contains dairy':
        return 'Dairy';
      case 'smartchoice':
        return 'Smart Choice';
      case 'HalalFriendly':
        return 'Halal';
      case 'Contains egg':
        return 'Eggs';
      case 'Contains soy':
        return 'Soy';
      case 'Contains gluten':
        return 'Gluten';
      case 'vegetarian':
        return 'Vegetarian';
      default:
        return 'Unknown';
    }
  }

  void updatePage(int index) {
    setState(() {
      currentPageIndex = index;
    });
    if (index == 1) {
      context.read<DiningBloc>().add(FoodFetchFoodsByFilters(
            diningHalls: diningHall,
          ));
    } else if (index == 2) {
      context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: updatePage,
        indicatorColor: Colors.transparent, // Transparent background
        indicatorShape: const CircleBorder(),
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home, size: 28, color: Colors.grey), // Unselected
            selectedIcon: Icon(Icons.home, size: 32, color: Colors.red[200]), // Selected icon color
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search, size: 28, color: Colors.grey),
            selectedIcon: Icon(Icons.search, size: 32, color: Colors.red[200]),
            label: 'Search',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite, size: 28, color: Colors.grey),
            selectedIcon: Icon(Icons.favorite, size: 32, color: Colors.red[200]),
            label: 'Favorites',
          ),
        ],
      ),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                size: 24,
                weight: 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search',
                  leading: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                  trailing: [
                    // Gray vertical divider
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey[400],
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    // Icon button
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          isScrollControlled: true,
                          builder: (context) {
                            return FilterCard(
                              selectedAllergens: selectedAllergens,
                              selectedMealTypes: selectedMealTypes,
                              selectedDietaryPreferences: selectedDietaryPreferences,
                              onApply: (allergens, mealTypes, dietaryPreferences) {
                                setState(() {
                                  selectedAllergens = allergens;
                                  selectedMealTypes = mealTypes;
                                  selectedDietaryPreferences = dietaryPreferences;
                                });
                                _filterItems();
                              },
                            ); // Your custom filter content
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              BlocConsumer<DiningBloc, DiningState>(
                listener: (context, state) {
                  if (state is DiningFailure) {
                    showSnackBar(context, state.error);
                  }
                  if (state is FoodGetFoodsByFiltersSuccess) {
                    setState(() {
                      items = state.foods; // Update list when data is fetched
                      allItems = List.from(state.foods);
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DiningLoading && items.isEmpty) {
                    return const Expanded(child: Center(child: CircularProgressIndicator())); // Show loading only when empty
                  }

                  if (items.isEmpty) {
                    return const Center(child: Text("No foods found."));
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: items.length > 200 ? 200 : items.length,
                      itemBuilder: (context, index) {
                        final food = items[index];
                        return ListTile(
                          title: Text(
                            food.name,
                            style: const TextStyle(fontFamily: 'Helvetica'),
                          ),
                          onTap: () {
                            context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());

                            Navigator.push(
                              context,
                              FoodPage.route(food, favoriteFoods),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          Column(
            children: [
              BlocConsumer<DiningBloc, DiningState>(
                listener: (context, state) {
                  if (state is FavoriteFoodsFailure) {
                    showSnackBar(context, state.error);
                  }
                  if (state is FetchFavoriteFoodsSuccess) {
                    setState(() {
                      favoriteFoods = state.foods;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is FavoriteFoodsLoading && items.isEmpty) {
                    return const Expanded(child: Center(child: CircularProgressIndicator())); // Show loading only when empty
                  }

                  if (favoriteFoods.isEmpty) {
                    return const Center(child: Text("No foods found."));
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: favoriteFoods.length > 200 ? 200 : favoriteFoods.length,
                      itemBuilder: (context, index) {
                        final food = favoriteFoods[index];
                        return ListTile(
                          title: Text(food.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              FoodPage.route(food, favoriteFoods),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ][currentPageIndex],
      ),
    );
  }
}
