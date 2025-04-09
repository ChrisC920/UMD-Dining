import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/food_page.dart';

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
  List<String> selectedMealTypes = [];
  List<Food> favoriteFoods = [];
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
    // setState(() {
    //   if (query.isEmpty) {
    //     items = allItems;
    //   }
    //   items = allItems
    //       .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
    //       .where((e) => mealTypes.every((type) => e.mealTypes.contains(type)))
    //       .toList();
    // });
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

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        items = List.from(allItems); // Show all items when search is empty
      } else {
        items = allItems.where((food) => food.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  void queryListener() {
    search(_searchController.text, selectedMealTypes);
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
          ),
        ),
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
              _mealTypeOptions(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search',
                  leading: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
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
                          title: Text(food.name),
                          onTap: () {
                            context.read<DiningBloc>().add(AddFavoriteFoodEvent(foodId: food.id));
                            Navigator.push(
                              context,
                              FoodPage.route(food),
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
                    print(state.foods);
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
                            context.read<DiningBloc>().add(AddFavoriteFoodEvent(foodId: food.id));
                            Navigator.push(
                              context,
                              FoodPage.route(food),
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

  SingleChildScrollView _mealTypeOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Constants.mealTypes
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    if (selectedMealTypes.contains(e)) {
                      selectedMealTypes.remove(e);
                    } else {
                      selectedMealTypes.add(e);
                    }
                    search(_searchController.text, selectedMealTypes);
                    setState(() {});
                  },
                  child: Chip(
                    label: Text(e),
                    color: selectedMealTypes.contains(e)
                        ? const WidgetStatePropertyAll(
                            AppPallete.gradient1,
                          )
                        : null,
                    side: selectedMealTypes.contains(e)
                        ? null
                        : const BorderSide(
                            color: AppPallete.borderColor,
                          ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
