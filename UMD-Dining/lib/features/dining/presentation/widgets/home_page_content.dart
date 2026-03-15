import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/core/constants/constants.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/bloc/dining_bloc.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/food_page.dart';

class HomePageContent extends StatefulWidget {
  final List<String>? diningHall;
  final List<Food> allFoods;
  final List<Food> favoriteFoods;
  final Set<String> localFavoriteIds;
  final DateTime? selectedDate;
  final void Function(int) onNavigate;
  final void Function(String foodId, bool isFav) onToggleFavorite;

  const HomePageContent({
    super.key,
    required this.diningHall,
    required this.allFoods,
    required this.favoriteFoods,
    required this.localFavoriteIds,
    required this.selectedDate,
    required this.onNavigate,
    required this.onToggleFavorite,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _activeMealFilter = 'All';

  // ── helpers ──────────────────────────────────────────────────────────────

  String get _hallDisplayName {
    final h = widget.diningHall;
    if (h == null || h.isEmpty) return 'All Halls';
    switch (h.first) {
      case '251 North':
        return '251 North';
      case 'Yahentamitsi':
        return 'Yahentamitsi';
      case 'South':
        return 'South Campus';
      default:
        return h.first;
    }
  }

  String get _hallImage {
    final h = widget.diningHall;
    if (h == null || h.isEmpty) return 'assets/images/random_food.jpg';
    switch (h.first) {
      case '251 North':
        return 'assets/images/251_North_Tables.jpg';
      case 'Yahentamitsi':
        return 'assets/images/Yahetamitsi_Dining_Hall.jpg';
      case 'South':
        return 'assets/images/South_Dining_Hall.jpg';
      default:
        return 'assets/images/random_food.jpg';
    }
  }

  String _currentMealPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour < 11) return 'Breakfast';
    if (hour >= 11 && hour < 15) return 'Lunch';
    if (hour >= 15 && hour < 21) return 'Dinner';
    return 'Brunch';
  }

  List<Food> get _filteredFoods {
    if (_activeMealFilter == 'All') return widget.allFoods;
    return widget.allFoods
        .where((f) => f.mealTypes.contains(_activeMealFilter))
        .toList();
  }

  // Featured = high protein foods (good picks for students)
  List<Food> get _featuredFoods {
    final foods = List<Food>.from(_filteredFoods);
    foods.sort((a, b) {
      final pa = double.tryParse(a.protein.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      final pb = double.tryParse(b.protein.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return pb.compareTo(pa);
    });
    return foods.take(6).toList();
  }

  // Low-calorie picks
  List<Food> get _lightPicks {
    final foods = List<Food>.from(_filteredFoods)
      ..sort((a, b) {
        final ca = int.tryParse(a.caloriesPerServing) ?? 999;
        final cb = int.tryParse(b.caloriesPerServing) ?? 999;
        return ca.compareTo(cb);
      });
    return foods.where((f) {
      final cal = int.tryParse(f.caloriesPerServing) ?? 999;
      return cal > 0 && cal < 400;
    }).take(6).toList();
  }

  // By section
  Map<String, List<Food>> get _bySection {
    final map = <String, List<Food>>{};
    for (final food in _filteredFoods) {
      for (final section in food.sections) {
        map.putIfAbsent(section, () => []).add(food);
      }
    }
    // Sort sections by number of items descending, take top 4
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return Map.fromEntries(sorted.take(4));
  }

  int _caloriesForFood(Food f) {
    final cal = int.tryParse(f.caloriesPerServing) ?? 0;
    final srv = int.tryParse(f.servingsPerContainer.split(' ').first) ?? 1;
    return cal * srv;
  }

  Color _calorieBadgeColor(int cal) {
    if (cal < 300) return Colors.green.shade600;
    if (cal < 600) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.allFoods.isEmpty;

    return BlocListener<DiningBloc, DiningState>(
      listener: (context, state) {
        if (state is FoodGetFoodsByFiltersSuccess) {
          setState(() {});
        }
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _heroHeader(),
          _quickStats(isLoading),
          _mealFilterChips(),
          if (isLoading) ...[
            _shimmerSection('Today\'s Top Picks'),
            _shimmerSection('Light Options'),
          ] else ...[
            if (_featuredFoods.isNotEmpty) _foodSection(
              title: 'Today\'s Top Picks 💪',
              subtitle: 'Highest protein options right now',
              foods: _featuredFoods,
            ),
            if (_lightPicks.isNotEmpty) _foodSection(
              title: 'Light Options 🥗',
              subtitle: 'Under 400 calories',
              foods: _lightPicks,
            ),
            ..._bySection.entries.map(
              (e) => _foodSection(
                title: e.key,
                subtitle: '${e.value.length} items available',
                foods: e.value.take(6).toList(),
              ),
            ),
            if (_filteredFoods.isEmpty) _emptyState(),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── hero header ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _heroHeader() {
    final dateStr = widget.selectedDate != null
        ? DateFormat('EEEE, MMMM d').format(widget.selectedDate!)
        : DateFormat('EEEE, MMMM d').format(DateTime.now());
    final meal = _currentMealPeriod();

    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppPallete.mainRed.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(_hallImage, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppPallete.mainRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        meal,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hallDisplayName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── quick stats ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _quickStats(bool isLoading) {
    final totalItems = widget.allFoods.length;
    final veganCount = widget.allFoods
        .where((f) => f.allergens.any((a) => a.toLowerCase() == 'vegan'))
        .length;
    final halalCount = widget.allFoods
        .where((f) => f.allergens.any((a) => a.toLowerCase().contains('halal')))
        .length;
    final favCount = widget.favoriteFoods.length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          children: [
            _statChip(
              icon: Icons.restaurant_menu,
              label: '$totalItems',
              sublabel: 'items',
              color: AppPallete.mainRed,
              isLoading: isLoading,
            ),
            const SizedBox(width: 10),
            _statChip(
              icon: Icons.eco,
              label: '$veganCount',
              sublabel: 'vegan',
              color: Colors.green.shade600,
              isLoading: isLoading,
            ),
            const SizedBox(width: 10),
            _statChip(
              icon: Icons.star_rounded,
              label: '$halalCount',
              sublabel: 'halal',
              color: Colors.amber.shade700,
              isLoading: isLoading,
            ),
            const SizedBox(width: 10),
            _statChip(
              icon: Icons.favorite,
              label: '$favCount',
              sublabel: 'saved',
              color: Colors.pink.shade400,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required bool isLoading,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 28,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
            Text(
              sublabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── meal type filter chips ─────────────────────────────────────────────────

  SliverToBoxAdapter _mealFilterChips() {
    final filters = ['All', ...Constants.mealTypes];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final label = filters[i];
            final active = _activeMealFilter == label;
            return GestureDetector(
              onTap: () => setState(() => _activeMealFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppPallete.mainRed : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppPallete.mainRed.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── section header + horizontal food card list ─────────────────────────────

  SliverToBoxAdapter _foodSection({
    required String title,
    required String subtitle,
    required List<Food> foods,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onNavigate(1),
                  child: Text(
                    'See all',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppPallete.mainRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _foodCard(foods[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ── food card ──────────────────────────────────────────────────────────────

  Widget _foodCard(Food food) {
    final isFav = widget.localFavoriteIds.contains(food.id);
    final calories = _caloriesForFood(food);
    final calColor = _calorieBadgeColor(calories);
    final protein = food.protein;
    final badges = _foodBadges(food);

    return GestureDetector(
      onTap: () {
        final clerkId = ClerkAuth.of(context).client.activeSession?.user.id ?? '';
        context.read<DiningBloc>().add(FetchFavoriteFoodsEvent(clerkId: clerkId));
        Navigator.push(
          context,
          FoodPage.route(
            food.id,
            widget.favoriteFoods,
            widget.diningHall ?? [],
            widget.selectedDate,
            food.mealTypes.toSet(),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top color block with calorie badge + fav button
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppPallete.mainRed.withValues(alpha: 0.12),
                        AppPallete.mainRed.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 36,
                      color: AppPallete.mainRed.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: calColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      calories > 0 ? '$calories cal' : '-- cal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => widget.onToggleFavorite(food.id, isFav),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Macros row
                    Row(
                      children: [
                        _macroTag('P', protein, Colors.blue.shade600),
                        const SizedBox(width: 4),
                        _macroTag('C', food.totalCarbohydrates, Colors.orange.shade600),
                        const SizedBox(width: 4),
                        _macroTag('F', food.totalFat, Colors.purple.shade400),
                      ],
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 0,
                        children: badges
                            .take(2)
                            .map((b) => _dietBadge(b))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroTag(String letter, String value, Color color) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = cleaned.isEmpty ? '--' : cleaned;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$letter:$num',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _dietBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Colors.green.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<String> _foodBadges(Food food) {
    final badges = <String>[];
    final allergens = food.allergens.map((a) => a.toLowerCase()).toList();
    if (allergens.contains('vegan')) badges.add('Vegan');
    if (allergens.contains('vegetarian')) badges.add('Veggie');
    if (allergens.any((a) => a.contains('halal'))) badges.add('Halal');
    return badges;
  }

  // ── shimmer skeleton ───────────────────────────────────────────────────────

  SliverToBoxAdapter _shimmerSection(String title) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── empty state ────────────────────────────────────────────────────────────

  SliverToBoxAdapter _emptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.no_meals, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No items for $_activeMealFilter',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different meal period',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}
