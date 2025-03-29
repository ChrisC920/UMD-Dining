import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/common/widgets/loader.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/dining.dart';
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
  List<Dining> allItems = [];
  List<Dining> items = [];
  List<Dining> searchHistory = [];
  List<String> selectedMealTypes = [];
  int currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    context.read<DiningBloc>().add(DiningFetchFoodQuery(
          diningHall: diningHall,
          mealType: selectedMealTypes,
        ));
    setState(() {
      currentPageIndex = 1;
    });
    _searchController.addListener(queryListener);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(queryListener);
    _searchController.dispose();
  }

  void search(String query, List<String> mealTypes) {
    setState(() {
      items = allItems
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .where((e) => mealTypes.every((type) => e.mealType.contains(type)))
          .toList();
    });
  }

  void queryListener() {
    search(_searchController.text, selectedMealTypes);
  }

  void updatePage(int index) {
    setState(() {
      currentPageIndex = index;
    });
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
            icon: const Icon(Icons.home,
                size: 28, color: Colors.grey), // Unselected
            selectedIcon: Icon(Icons.home,
                size: 32, color: Colors.red[200]), // Selected icon color
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search, size: 28, color: Colors.grey),
            selectedIcon: Icon(Icons.search, size: 32, color: Colors.red[200]),
            label: 'Search',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite, size: 28, color: Colors.grey),
            selectedIcon: Icon(Icons.abc, size: 32, color: Colors.red[200]),
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
          BlocConsumer<DiningBloc, DiningState>(
            listener: (context, state) {
              if (state is DiningFailure) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is DiningLoading) {
                return const Loader();
              }
              if (state is DiningGetFoodQuerySuccess) {
                allItems = state.foods;
                return Column(
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length > 100 ? 100 : items.length,
                        itemBuilder: (context, index) {
                          final food = items[index];
                          return ListTile(
                            title: Text(food.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                FoodPage.route(food),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox(
                child: Text("ERROR"),
              );
            },
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        ][currentPageIndex],
      ),
    );
  }

  NavigationDestination _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.blue, // Circular background color when selected
          shape: BoxShape.circle,
        ),
        child: Icon(selectedIcon, color: Colors.white),
      ),
      label: '', // Hide label
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
