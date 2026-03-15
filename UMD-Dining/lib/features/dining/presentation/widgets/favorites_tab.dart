import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';
import 'package:umd_dining_refactor/features/dining/presentation/pages/food_page.dart';

class FavoritesTab extends StatelessWidget {
  final List<Food> favoriteFoods;
  final Set<String> localFavoriteIds;
  final void Function(String foodId, bool isFav) onToggleFavorite;
  final List<String>? selectedHalls;
  final DateTime selectedDate;

  const FavoritesTab({
    super.key,
    required this.favoriteFoods,
    required this.localFavoriteIds,
    required this.onToggleFavorite,
    required this.selectedHalls,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Saved Foods',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppPallete.mainRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${favoriteFoods.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.mainRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (favoriteFoods.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing saved yet',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart on any food to save it here',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: favoriteFoods.length,
                itemBuilder: (context, i) => _FavoriteCard(
                  food: favoriteFoods[i],
                  isFavorite: localFavoriteIds.contains(favoriteFoods[i].id),
                  onToggleFavorite: () => onToggleFavorite(
                    favoriteFoods[i].id,
                    localFavoriteIds.contains(favoriteFoods[i].id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      FoodPage.route(
                        favoriteFoods[i].id,
                        favoriteFoods,
                        selectedHalls ?? [],
                        selectedDate,
                        favoriteFoods[i].mealTypes.toSet(),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Food food;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.food,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  Color _calColor(int cal) {
    if (cal < 300) return Colors.green.shade600;
    if (cal < 600) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final cal = int.tryParse(food.caloriesPerServing) ?? 0;
    final allergens = food.allergens.map((a) => a.toLowerCase()).toList();
    final badges = <String>[];
    if (allergens.contains('vegan')) badges.add('Vegan');
    else if (allergens.contains('vegetarian')) badges.add('Veggie');
    if (allergens.any((a) => a.contains('halal'))) badges.add('Halal');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top banner
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppPallete.mainRed.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Icon(Icons.favorite, size: 32, color: AppPallete.mainRed.withValues(alpha: 0.4)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _calColor(cal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      cal > 0 ? '$cal cal' : '-- cal',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                    if (badges.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: badges.take(2).map((b) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(b, style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    if (food.sections.isNotEmpty)
                      Text(
                        food.sections.first,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.black38),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
