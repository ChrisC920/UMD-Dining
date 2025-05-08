import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
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
  Set<int> localFavoriteIds = {};
  Set<String> selectedMealTypes = <String>{};
  Set<String> selectedAllergens = <String>{};
  Set<String> selectedDietaryPreferences = <String>{};
  DateTime? selectedDate = DateTime.now();
  int currentPageIndex = 1;
  final ScrollController _scrollController = ScrollController();
  int visibleItemCount = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(handleScroll);

    // if (currentPageIndex == 1) {
    context.read<DiningBloc>().add(FoodFetchFoodsByFilters(diningHalls: diningHall, date: selectedDate));
    // } else if (currentPageIndex == 2) {
    context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
    // }
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
    _scrollController.dispose();
  }

  void handleScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (visibleItemCount < items.length) {
        setState(() {
          visibleItemCount += 20;
        });
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      visibleItemCount = 20;
      items = allItems.where((food) {
        final matchesFilters = selectedMealTypes.every((type) => food.mealTypes.contains(type)) &&
            selectedDietaryPreferences.every((pref) => convertAllergenList(food.allergens).contains(pref)) &&
            selectedAllergens.every((allergen) => !convertAllergenList(food.allergens).contains(allergen));

        if (query.isEmpty) {
          return matchesFilters; // Show all filtered items if query is empty
        }

        final name = food.name.toLowerCase();
        final similarity = StringSimilarity.compareTwoStrings(name, query);
        final isMatch = name.contains(query) || similarity > 0.4;

        return isMatch && matchesFilters;
      }).toList();
      items.sort((a, b) {
        final simA = StringSimilarity.compareTwoStrings(a.name.toLowerCase(), query);
        final simB = StringSimilarity.compareTwoStrings(b.name.toLowerCase(), query);
        return simB.compareTo(simA); // Higher similarity first
      });
    });
  }

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
      context.read<DiningBloc>().add(FoodFetchFoodsByFilters(diningHalls: diningHall, date: selectedDate));
    } else if (index == 2) {
      context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(),
      appBar: _appBar(),
      body: SafeArea(
        child: <Widget>[
          _homePage(),
          _searchPage(context),
          _favoritesPage(),
        ][currentPageIndex],
      ),
    );
  }

  Center _homePage() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.green,
      ),
    );
  }

  Column _favoritesPage() {
    return Column(
      children: [
        _favoriteFoodResults(),
      ],
    );
  }

  Column _searchPage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: _searchBar(context),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // onTap: () {
            //   FocusScope.of(context).unfocus();
            // },
            child: _searchResults(),
          ),
        ),
      ],
    );
  }

  BlocConsumer<DiningBloc, DiningState> _favoriteFoodResults() {
    return BlocConsumer<DiningBloc, DiningState>(
      listener: (context, state) {
        if (state is FavoriteFoodsFailure) {
          showSnackBar(context, state.error);
        }
        if (state is FetchFavoriteFoodsSuccess && currentPageIndex == 2) {
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
                    FoodPage.route(food.id, favoriteFoods, diningHall!, null, selectedMealTypes),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  BlocConsumer<DiningBloc, DiningState> _searchResults() {
    return BlocConsumer<DiningBloc, DiningState>(
      listener: (context, state) {
        if (state is DiningFailure) {
          showSnackBar(context, state.error);
        }
        if (state is FoodGetFoodsByFiltersSuccess) {
          setState(() {
            items = state.foods;
            allItems = state.foods;
            // allItems = List.from(state.foods);
            _filterItems();
          });
        }
        if (state is FetchFavoriteFoodsSuccess) {
          setState(() {
            favoriteFoods = state.foods;
            localFavoriteIds = favoriteFoods.map((f) => f.id).toSet();
          });
        }
        if (state is AddFavoriteFoodSuccess) {
          localFavoriteIds.add(state.foodId);
          favoriteFoods.add(allItems.firstWhere((food) => food.id == state.foodId));
        }
        if (state is DeleteFavoriteFoodSuccess) {
          localFavoriteIds.remove(state.foodId);
          favoriteFoods.removeWhere((food) => food.id == state.foodId);
        }
      },
      builder: (context, state) {
        if (state is DiningLoading) {
          return const Expanded(child: Center(child: CircularProgressIndicator()));
        }

        if (items.isEmpty) {
          return const Center(child: Text("No foods found."));
        }

        final displayedItems = items.take(visibleItemCount).toList();

        return Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 8,
            ),
            controller: _scrollController,
            itemCount: displayedItems.length,
            itemBuilder: (context, index) {
              final food = displayedItems[index];
              bool isFavorite = favoriteFoods.any((aFood) => aFood.id == food.id);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<DiningBloc>().add(FetchFavoriteFoodsEvent());

                  Navigator.push(
                    context,
                    FoodPage.route(food.id, favoriteFoods, diningHall!, selectedDate, selectedMealTypes),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food name wraps if too long
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8), // space between text
                          // Calories aligned right
                          Row(
                            children: [
                              Text(
                                '${food.caloriesPerServing} cal',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.orangeAccent,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Wrap(
                      //   spacing: 8,
                      //   runSpacing: 4,
                      //   children: [
                      //     ...food.mealTypes.map((meal) => _tagChip(meal)),
                      //     ...food.allergens.map((allergen) => _tagChip(allergen, isAllergen: true)),
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      // Macros
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Protein: ${food.protein}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                // const SizedBox(width: 6),
                                Flexible(
                                  flex: 5,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Carbs: ${food.totalCarbohydrates}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Fat: ${food.totalFat}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              localFavoriteIds.contains(food.id) ? Icons.favorite : Icons.favorite_outline,
                              color: localFavoriteIds.contains(food.id) ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (localFavoriteIds.contains(food.id)) {
                                  localFavoriteIds.remove(food.id);
                                  context.read<DiningBloc>().add(DeleteFavoriteFoodEvent(foodId: food.id));
                                } else {
                                  localFavoriteIds.add(food.id);
                                  context.read<DiningBloc>().add(AddFavoriteFoodEvent(foodId: food.id));
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Widget _tagChip(String label, {bool isAllergen = false}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade200,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         if (isAllergen) const Icon(Icons.warning, size: 14, color: Colors.black54),
  //         if (isAllergen) const SizedBox(width: 4),
  //         Text(label, style: const TextStyle(fontSize: 14)),
  //       ],
  //     ),
  //   );
  // }

  SearchBar _searchBar(BuildContext context) {
    return SearchBar(
      backgroundColor: const WidgetStatePropertyAll(Color(0x00ecf0f1)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            style: BorderStyle.solid,
            color: Colors.grey,
            width: 0.6,
          ),
        ),
      ),
      hintStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 2)),
      controller: _searchController,
      hintText: 'Search for food items...',
      leading: IconButton(
        icon: const Icon(Icons.search, color: Colors.grey),
        onPressed: () {},
      ),
      trailing: [
        Container(
          height: 24,
          width: 1,
          color: Colors.grey[400],
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),
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
                  selectedDate: selectedDate,
                  onApply: (allergens, mealTypes, dietaryPreferences, date) {
                    if (date != selectedDate) {
                      context.read<DiningBloc>().add(FoodFetchFoodsByFilters(diningHalls: diningHall, date: selectedDate));
                    }
                    setState(() {
                      selectedAllergens = allergens;
                      selectedMealTypes = mealTypes;
                      selectedDietaryPreferences = dietaryPreferences;
                      selectedDate = date;
                    });
                    _filterItems();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppPallete.mainRed,
      title: const Text(
        "UMD Dining",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Helvetica',
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      elevation: 1.0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.person, size: 24, weight: 24, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  NavigationBar _bottomNavBar() {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      onDestinationSelected: updatePage,
      indicatorColor: Colors.transparent,
      indicatorShape: const CircleBorder(),
      selectedIndex: currentPageIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home, size: 28, color: Colors.grey),
          selectedIcon: Icon(Icons.home, size: 32, color: AppPallete.mainRed),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search, size: 28, color: Colors.grey),
          selectedIcon: Icon(Icons.search, size: 32, color: AppPallete.mainRed),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite, size: 28, color: Colors.grey),
          selectedIcon: Icon(Icons.favorite, size: 32, color: AppPallete.mainRed),
          label: 'Favorites',
        ),
      ],
    );
  }
}
