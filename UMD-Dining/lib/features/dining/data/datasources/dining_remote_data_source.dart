import 'dart:convert';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:intl/intl.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

abstract interface class DiningRemoteDataSource {
  Future<List<Food>> getFoodById({
    required String id,
    String? diningHall,
    DateTime? date,
  });
  Future<List<Food>> getFoodsByFilters({
    DateTime? date,
    List<String>? diningHalls,
    List<String>? mealTypes,
    List<String>? sections,
    List<String>? allergens,
  });
  Future<String> addFavoriteFood({required String clerkId, required String foodId});
  Future<String> deleteFavoriteFood({required String clerkId, required String foodId});
  Future<List<Food>> fetchFavoriteFoods({required String clerkId});
}

class DiningRemoteDataSourceImpl implements DiningRemoteDataSource {
  final ConvexClient convexClient;
  DiningRemoteDataSourceImpl(this.convexClient);

  @override
  Future<List<Food>> getFoodsByFilters({
    DateTime? date,
    List<String>? diningHalls,
    List<String>? mealTypes,
    List<String>? sections,
    List<String>? allergens,
  }) async {
    try {
      final args = <String, dynamic>{};
      if (date != null) args['date'] = DateFormat('yyyy-MM-dd').format(date);
      if (diningHalls != null && diningHalls.isNotEmpty) args['diningHallNames'] = diningHalls;
      if (mealTypes != null && mealTypes.isNotEmpty) args['mealTypeNames'] = mealTypes;
      if (sections != null && sections.isNotEmpty) args['sectionNames'] = sections;
      if (allergens != null && allergens.isNotEmpty) args['allergenExclusions'] = allergens;

      // query() uses positional parameters in convex_flutter v3
      final raw = await convexClient.query('foods:getFoodsByFilters', args);
      final Map<String, dynamic> result = jsonDecode(raw);
      final List<dynamic> foodsJson = result['foods'] as List<dynamic>;

      return foodsJson
          .map((f) => Food.fromConvex(f as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Food>> getFoodById({
    required String id,
    String? diningHall,
    DateTime? date,
  }) async {
    try {
      final raw = await convexClient.query('foods:getFoodById', {'foodId': id});
      final dynamic decoded = jsonDecode(raw);
      if (decoded == null) return [];
      return [Food.fromConvexDetail(decoded as Map<String, dynamic>)];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> addFavoriteFood({required String clerkId, required String foodId}) async {
    try {
      await convexClient.mutation(
        name: 'favorites:addFavorite',
        args: {'clerkId': clerkId, 'foodId': foodId},
      );
      return foodId;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> deleteFavoriteFood({required String clerkId, required String foodId}) async {
    try {
      await convexClient.mutation(
        name: 'favorites:removeFavorite',
        args: {'clerkId': clerkId, 'foodId': foodId},
      );
      return foodId;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Food>> fetchFavoriteFoods({required String clerkId}) async {
    try {
      final raw = await convexClient.query(
        'favorites:getUserFavorites',
        {'clerkId': clerkId},
      );
      final List<dynamic> foodsJson = jsonDecode(raw) as List<dynamic>;
      return foodsJson
          .map((f) => Food.fromConvex(f as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
