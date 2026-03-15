import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/utils/show_snackbar.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/explore_tab.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/favorites_tab.dart';
import 'package:umd_dining_refactor/features/dining/presentation/widgets/home_page_content.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/profile_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static route() => MaterialPageRoute(builder: (_) => const MainShell());

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  List<Food> _allFoods = [];
  List<Food> _favoriteFoods = [];
  Set<String> _localFavoriteIds = {};
  DateTime _selectedDate = DateTime.now();
  List<String>? _selectedHalls; // null = all halls

  String get _clerkId => ClerkAuth.of(context).client.activeSession?.user.id ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiningBloc>().add(FoodFetchFoodsByFilters(
            diningHalls: _selectedHalls,
            date: _selectedDate,
          ));
      context.read<DiningBloc>().add(FetchFavoriteFoodsEvent(clerkId: _clerkId));
    });
  }

  void _toggleFavorite(String foodId, bool isFav) {
    setState(() {
      if (isFav) {
        _localFavoriteIds.remove(foodId);
        context.read<DiningBloc>().add(DeleteFavoriteFoodEvent(clerkId: _clerkId, foodId: foodId));
      } else {
        _localFavoriteIds.add(foodId);
        context.read<DiningBloc>().add(AddFavoriteFoodEvent(clerkId: _clerkId, foodId: foodId));
      }
    });
  }

  void _switchHall(List<String>? halls) {
    setState(() {
      _selectedHalls = halls;
    });
    context.read<DiningBloc>().add(FoodFetchFoodsByFilters(
          diningHalls: halls,
          date: _selectedDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiningBloc, DiningState>(
      listener: (context, state) {
        if (state is DiningFailure) showSnackBar(context, state.error);
        if (state is FavoriteFoodsFailure) showSnackBar(context, state.error);
        if (state is FoodGetFoodsByFiltersSuccess) {
          setState(() {
            _allFoods = state.foods;
          });
        }
        if (state is FetchFavoriteFoodsSuccess) {
          setState(() {
            _favoriteFoods = state.foods;
            _localFavoriteIds = _favoriteFoods.map((f) => f.id).toSet();
          });
        }
        if (state is AddFavoriteFoodSuccess) {
          setState(() {
            _localFavoriteIds.add(state.foodId);
            final food = _allFoods.firstWhere(
              (f) => f.id == state.foodId,
              orElse: () => _favoriteFoods.firstWhere((f) => f.id == state.foodId, orElse: Food.empty),
            );
            if (food.id.isNotEmpty && !_favoriteFoods.any((f) => f.id == food.id)) {
              _favoriteFoods = List.from(_favoriteFoods)..add(food);
            }
          });
        }
        if (state is DeleteFavoriteFoodSuccess) {
          setState(() {
            _localFavoriteIds.remove(state.foodId);
            _favoriteFoods = _favoriteFoods.where((f) => f.id != state.foodId).toList();
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _homeTab(),
            ExploreTab(
              allFoods: _allFoods,
              localFavoriteIds: _localFavoriteIds,
              onToggleFavorite: _toggleFavorite,
              selectedHalls: _selectedHalls,
              selectedDate: _selectedDate,
            ),
            FavoritesTab(
              favoriteFoods: _favoriteFoods,
              localFavoriteIds: _localFavoriteIds,
              onToggleFavorite: _toggleFavorite,
              selectedHalls: _selectedHalls,
              selectedDate: _selectedDate,
            ),
            const ProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppPallete.mainRed),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search, color: AppPallete.mainRed),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite, color: AppPallete.mainRed),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppPallete.mainRed),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeTab() {
    return SafeArea(
      child: Column(
        children: [
          _HallSelectorBar(
            selectedHalls: _selectedHalls,
            onHallSelected: _switchHall,
          ),
          Expanded(
            child: HomePageContent(
              diningHall: _selectedHalls,
              allFoods: _allFoods,
              favoriteFoods: _favoriteFoods,
              localFavoriteIds: _localFavoriteIds,
              selectedDate: _selectedDate,
              onNavigate: (index) => setState(() => _selectedIndex = index),
              onToggleFavorite: _toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}

class _HallSelectorBar extends StatelessWidget {
  final List<String>? selectedHalls;
  final void Function(List<String>?) onHallSelected;

  const _HallSelectorBar({
    required this.selectedHalls,
    required this.onHallSelected,
  });

  @override
  Widget build(BuildContext context) {
    final halls = [null, ['251 North'], ['Yahentamitsi'], ['South']];
    final labels = ['All', '251 North', 'Yahentamitsi', 'South'];

    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: halls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = (selectedHalls == null && halls[i] == null) ||
              (selectedHalls != null &&
                  halls[i] != null &&
                  selectedHalls!.isNotEmpty &&
                  halls[i]!.isNotEmpty &&
                  selectedHalls!.first == halls[i]!.first);
          return GestureDetector(
            onTap: () => onHallSelected(halls[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppPallete.mainRed : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
