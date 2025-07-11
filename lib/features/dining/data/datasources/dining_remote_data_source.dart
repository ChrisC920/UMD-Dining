import 'package:intl/intl.dart';
import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

abstract interface class DiningRemoteDataSource {
  Future<List<Food>> getFoodById({
    required int id,
    String? diningHall,
    DateTime? date,
  });
  Future<List<Food>> getFoodsByFilters({
    DateTime? date, // List of dates (YYYY-MM-DD) to query by
    List<String>? diningHalls, // List of dining hall names
    List<String>? mealTypes, // List of meal type names
    List<String>? sections,
    List<String>? allergens,
  });
  Future<int> addFavoriteFood({required int foodId});
  Future<int> deleteFavoriteFood({required int foodId});
  Future<List<Food>> fetchFavoriteFoods();
}

class DiningRemoteDataSourceImpl implements DiningRemoteDataSource {
  final SupabaseClient supabaseClient;
  DiningRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<Food>> getFoodsByFilters({
    DateTime? date, // List of dates (YYYY-MM-DD) to query by
    List<String>? diningHalls, // List of dining hall names
    List<String>? mealTypes, // List of meal type names
    List<String>? sections, // List of section names
    List<String>? allergens,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query;

      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);

        final dateRes = await supabaseClient.from('dates').select('id').eq('date', formattedDate).maybeSingle(); // Returns null if not found

        if (dateRes == null) {
          throw Exception("Date not found in 'dates' table");
        }

        final dateId = dateRes['id'];
        query = supabaseClient.from('food_relations').select(r'''
      food_id,
      food:foods!inner(
        name,
        link,
        serving_size,
        servings_per_container,
        calories_per_serving,
        total_fat,
        saturated_fat,
        trans_fat,
        cholesterol,
        sodium,
        total_carbohydrates,
        dietary_fiber,
        total_sugars,
        added_sugars,
        protein,
        food_allergens!left (allergens (name))
      ),
      dining_hall:dining_halls!inner(name),
      meal_type:meal_types!inner(name),
      section:sections!inner(name),
      date:dates!inner(date)
    ''').eq('date_id', dateId);
      } else {
        query = supabaseClient.from('food_relations').select('''
  food_id,
      food:foods!inner(
        name,
        link,
        serving_size,
        servings_per_container,
        calories_per_serving,
        total_fat,
        saturated_fat,
        trans_fat,
        cholesterol,
        sodium,
        total_carbohydrates,
        dietary_fiber,
        total_sugars,
        added_sugars,
        protein,
        food_allergens!left (allergens (name))
      ),
      dining_hall:dining_halls!inner(name),
      meal_type:meal_types!inner(name),
      section:sections!inner(name),
      date:dates!inner(date)
''');
      }

      // Filter by dining hall names
      // if (diningHalls != null && diningHalls.length == 1) {
      //   final diningHallRes = await supabaseClient.from('dining_halls').select('*').eq('name', diningHalls.first).single();
      //   query = query.eq('dining_hall_id', diningHallRes['id']);
      //   print("SINGLE DINING HALL FILTER");
      /*} else */ if (diningHalls != null && diningHalls.isNotEmpty) {
        final diningHallsRes = await supabaseClient.from('dining_halls').select('id, name').inFilter('name', diningHalls);
        final ids = diningHallsRes.map((e) => e['id']).toList();
        query = query.inFilter('dining_hall_id', ids);
      }

      // Filter by meal type names
      if (mealTypes != null && mealTypes.isNotEmpty) {
        final mealTypesRes = await supabaseClient.from('meal_types').select('id, name').inFilter('name', mealTypes);
        final ids = mealTypesRes.map((e) => e['id']).toList();
        query = query.inFilter('meal_type_id', ids);
      }

      // Filter by section names
      if (sections != null && sections.isNotEmpty) {
        final sectionsRes = await supabaseClient.from('sections').select('id, name').inFilter('name', sections);
        final ids = sectionsRes.map((e) => e['id']).toList();
        query = query.inFilter('section_id', ids);
      }

      if (allergens != null && allergens.isNotEmpty) {
        final allergensRes = await supabaseClient.from('allergens').select('id, name').inFilter('name', allergens);
        final ids = allergensRes.map((e) => e['id']).toList();
        query = query.inFilter('allergen_id', ids);
      }

      final response = await query;

      final foods = response
          .map((food) {
            try {
              return Food.fromJsonAlt(food);
            } catch (e) {
              return null;
            }
            // } catch (e, stacktrace) {
            // print("Error parsing food item: $food");
            // print("Error details: $e");
            // print("Stacktrace: $stacktrace");
            //   return null;
            // }
          })
          .whereType<Food>()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

// Remove duplicates by name while keeping the first occurrence
      final uniqueFoods = foods
          .fold<Map<String, Food>>({}, (map, food) {
            // Sort dates to make sure the key is consistent
            final sortedDates = [...food.dates]..sort();
            final datesKey = sortedDates.join(',');

            final key = '${food.name}|${food.caloriesPerServing}|$datesKey';
            // print("KEY $key");

            if (map.containsKey(key)) {
              final existing = map[key]!;

              map[key] = Food(
                id: existing.id,
                name: existing.name,
                link: existing.link,
                servingSize: existing.servingSize,
                servingsPerContainer: existing.servingsPerContainer,
                caloriesPerServing: existing.caloriesPerServing,
                totalFat: existing.totalFat,
                saturatedFat: existing.saturatedFat,
                transFat: existing.transFat,
                totalCarbohydrates: existing.totalCarbohydrates,
                dietaryFiber: existing.dietaryFiber,
                totalSugars: existing.totalSugars,
                addedSugars: existing.addedSugars,
                cholesterol: existing.cholesterol,
                sodium: existing.sodium,
                protein: existing.protein,
                diningHalls: {...existing.diningHalls, ...food.diningHalls}.toSet().toList(),
                mealTypes: {...existing.mealTypes, ...food.mealTypes}.toSet().toList(),
                sections: {...existing.sections, ...food.sections}.toSet().toList(),
                allergens: {...existing.allergens, ...food.allergens}.toSet().toList(),
                dates: {...existing.dates, ...food.dates}.toSet().toList(),
                // dates: existing.dates,
              );
            } else {
              map[key] = food;
            }

            return map;
          })
          .values
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return uniqueFoods;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Food>> getFoodById({required int id, String? diningHall, DateTime? date}) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query;
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);

        final dateRes = await supabaseClient.from('dates').select('id').eq('date', formattedDate).maybeSingle(); // Returns null if not found

        if (dateRes == null) {
          throw Exception("Date not found in 'dates' table");
        }

        final dateId = dateRes['id'];
        query = supabaseClient.from('food_relations').select(r'''
      food_id,
      food:foods!inner(
        name,
        link,
        serving_size,
        servings_per_container,
        calories_per_serving,
        total_fat,
        saturated_fat,
        trans_fat,
        cholesterol,
        sodium,
        total_carbohydrates,
        dietary_fiber,
        total_sugars,
        added_sugars,
        protein,
        food_allergens!left (allergens (name))
      ),
      dining_hall:dining_halls!inner(name),
      meal_type:meal_types!inner(name),
      section:sections!inner(name),
      date:dates!inner(date)
    ''').eq('food_id', id).eq('date_id', dateId);
      } else {
        query = supabaseClient.from('food_relations').select('''
  food_id,
  foods!inner (
    id, name, link, serving_size, servings_per_container, calories_per_serving, total_fat, saturated_fat, trans_fat,
    total_carbohydrates, dietary_fiber, total_sugars, added_sugars, cholesterol, sodium, protein,
    food_allergens!left (allergens (id, name)),
    food_dining_halls!left (dining_halls (id, name)),
    food_meal_types!left (meal_types (id, name)),
    food_sections!left (sections (id, name)),
    food_dates!left (dates (id, date))
  )
''').eq('food_id', id);
      }

      final response = await query;
      final foods = response
          .map((food) {
            try {
              return Food.fromJsonAlt(food);
            } catch (e) {
              return null;
            }
            // catch (e, stacktrace) {
            //   print("Error parsing food item: $food");
            //   print("Error details: $e");
            //   print("Stacktrace: $stacktrace");
            //   return null;
            // }
          })
          .whereType<Food>()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return foods;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  List<Food> mergeDuplicateFoods(List<Food> foods) {
    Map<String, Food> foodMap = {};

    for (var food in foods) {
      if (foodMap.containsKey(food.name)) {
        // Get the existing food entry
        var existingFood = foodMap[food.name]!;

        // Merge unique dining halls, meal types, and sections
        existingFood.diningHalls = {...existingFood.diningHalls, ...food.diningHalls}.toList();
        existingFood.mealTypes = {...existingFood.mealTypes, ...food.mealTypes}.toList();
        existingFood.sections = {...existingFood.sections, ...food.sections}.toList();
        existingFood.allergens = {...existingFood.allergens, ...food.allergens}.toList();
        existingFood.dates = {...existingFood.dates, ...food.dates}.toList();
      } else {
        // Add the food to the map if it doesn't exist
        foodMap[food.name] = food;
      }
    }

    return foodMap.values.toList();
  }

  @override
  Future<int> addFavoriteFood({required int foodId}) async {
    try {
      await supabaseClient.from('user_favorites').upsert({
        'user_id': supabaseClient.auth.currentUser!.id,
        'food_id': foodId,
      }, onConflict: 'user_id, food_id', ignoreDuplicates: true);
      return foodId;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> deleteFavoriteFood({required int foodId}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception("No user logged in");

      await supabaseClient.from('user_favorites').delete().match({
        'user_id': userId,
        'food_id': foodId,
      });
      return foodId;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Food>> fetchFavoriteFoods() async {
    try {
      final query = supabaseClient.from('user_favorites').select('''
    food_id,
    foods!inner (
      id, name, link, serving_size, servings_per_container, calories_per_serving, total_fat, saturated_fat, trans_fat,
      total_carbohydrates, dietary_fiber, total_sugars, added_sugars, cholesterol, sodium, protein,
      food_allergens!left (allergens (id, name)),
      food_dining_halls!left (dining_halls (id, name)),
      food_meal_types!left (meal_types (id, name)),
      food_sections!left (sections (id, name)),
      food_dates!left (dates (id, date))
    )
  ''').eq('user_id', supabaseClient.auth.currentUser!.id);
      final response = await query;
      final foods = response
          .map((food) {
            try {
              return Food.fromJson(food);
            } catch (e) {
              return null;
            }
            // } catch (e, stacktrace) {
            //   print("Error parsing food item: $food");
            //   print("Error details: $e");
            //   print("Stacktrace: $stacktrace");
            //   return null;
            // }
          })
          .whereType<Food>()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

// Remove duplicates by name while keeping the first occurrence
      final uniqueFoods = foods
          .fold<Map<String, Food>>({}, (map, food) {
            final key = '${food.name}|${food.caloriesPerServing}';

            if (map.containsKey(key)) {
              final existing = map[key]!;

              map[key] = Food(
                id: existing.id,
                name: existing.name,
                link: existing.link,
                servingSize: existing.servingSize,
                servingsPerContainer: existing.servingsPerContainer,
                caloriesPerServing: existing.caloriesPerServing,
                totalFat: existing.totalFat,
                saturatedFat: existing.saturatedFat,
                transFat: existing.transFat,
                totalCarbohydrates: existing.totalCarbohydrates,
                dietaryFiber: existing.dietaryFiber,
                totalSugars: existing.totalSugars,
                addedSugars: existing.addedSugars,
                cholesterol: existing.cholesterol,
                sodium: existing.sodium,
                protein: existing.protein,
                diningHalls: {...existing.diningHalls, ...food.diningHalls}.toSet().toList(),
                mealTypes: {...existing.mealTypes, ...food.mealTypes}.toSet().toList(),
                sections: {...existing.sections, ...food.sections}.toSet().toList(),
                allergens: {...existing.allergens, ...food.allergens}.toSet().toList(),
                dates: {...existing.dates, ...food.dates}.toSet().toList(),
              );
            } else {
              map[key] = food;
            }

            return map;
          })
          .values
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return uniqueFoods;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

bool isMergeable(Food a, Food b) {
  return a.link == b.link && a.caloriesPerServing == b.caloriesPerServing && a.servingSize == b.servingSize;
  // Add any other checks for nutritional equivalence here
}

Food mergeFoods(Food a, Food b) {
  return Food(
    id: a.id,
    name: a.name,
    link: a.link,
    servingSize: a.servingSize,
    servingsPerContainer: a.servingsPerContainer,
    caloriesPerServing: a.caloriesPerServing,
    totalFat: a.totalFat,
    saturatedFat: a.saturatedFat,
    transFat: a.transFat,
    totalCarbohydrates: a.totalCarbohydrates,
    dietaryFiber: a.dietaryFiber,
    totalSugars: a.totalSugars,
    addedSugars: a.addedSugars,
    cholesterol: a.cholesterol,
    sodium: a.sodium,
    protein: a.protein,
    diningHalls: {...a.diningHalls, ...b.diningHalls}.toSet().toList(),
    mealTypes: {...a.mealTypes, ...b.mealTypes}.toSet().toList(),
    sections: {...a.sections, ...b.sections}.toSet().toList(),
    allergens: {...a.allergens, ...b.allergens}.toSet().toList(),
    dates: {...a.dates, ...b.dates}.toSet().toList(),
  );
}
