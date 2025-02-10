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
  List<GButton> navigations = Constants.getNavigations();
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DiningBloc>().add(DiningFetchFoodQuery(
          diningHall: diningHall,
          mealType: selectedMealTypes,
        ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              gap: 8,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              haptic: true,
              tabs: navigations,
              selectedIndex: currentPageIndex,
              onTabChange: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
          ),
        ),
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
                Icons.search,
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
          Center(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
          Center(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
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
