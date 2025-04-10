import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/features/dining/data/models/dining_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:umd_dining_refactor/features/dining/domain/entities/food.dart';

abstract interface class DiningRemoteDataSource {
  Future<List<DiningModel>> getAllFoods({
    required String database,
  });
  Future<DiningModel> getFood({
    required String name,
  });
  Future<List<DiningModel>> getFoodQuery({
    int? id,
    String? name,
    String? link,
    String? servingSize,
    String? servingsPerContainer,
    String? caloriesPerServing,
    String? totalFat,
    String? saturatedFat,
    String? transFat,
    String? cholesterol,
    String? sodium,
    String? totalCarbohydrates,
    String? dietaryFiber,
    String? totalSugar,
    String? addedSugar,
    String? protein,
  });
  Future<Food> getFoodById({required int id});
  Future<List<Food>> getFoodsByFilters({
    List<String>? dates, // List of dates (YYYY-MM-DD) to query by
    List<String>? diningHalls, // List of dining hall names
    List<String>? mealTypes, // List of meal type names
    List<String>? sections,
    List<String>? allergens,
  });
  Future<void> addFavoriteFood({required int foodId});
  Future<void> deleteFavoriteFood({required int foodId});
  Future<List<Food>> fetchFavoriteFoods();
}

class DiningRemoteDataSourceImpl implements DiningRemoteDataSource {
  final SupabaseClient supabaseClient;
  DiningRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<Food>> getFoodsByFilters({
    List<String>? dates, // List of dates (YYYY-MM-DD) to query by
    List<String>? diningHalls, // List of dining hall names
    List<String>? mealTypes, // List of meal type names
    List<String>? sections, // List of section names
    List<String>? allergens,
  }) async {
    try {
      var query = supabaseClient.from('food_relations').select('''
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
''');

      // Filter by multiple dates
      if (dates != null && dates.isNotEmpty) {
        final datesRes = await supabaseClient.from('dates').select('id, date').inFilter('date', dates);
        final ids = datesRes.map((e) => e['id']).toList();
        query = query.inFilter('date_id', ids);
      }

      // Filter by dining hall names
      if (diningHalls != null && diningHalls.isNotEmpty) {
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
              return Food.fromJson(food);
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
            // Use name + diningHall combo as a unique key
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
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Food> getFoodById({required int id}) async {
    final response = await supabaseClient.from('foods').select('''
            id, name, link, serving_size, servings_per_container,
            calories_per_serving, total_fat, saturated_fat, trans_fat,
            total_carbohydrates, dietary_fiber, total_sugars, added_sugars,
            cholesterol, sodium, protein,
            food_allergens(allergens(id, name)),
            food_meal_types(meal_types(id, name)),
            food_dining_halls(dining_halls(id, name)),
            food_sections(sections(id, name))
          ''').eq('id', id).single();

    return Food.fromJson(response);
  }

  @override
  Future<List<DiningModel>> getAllFoods({required String database}) async {
    try {
      final foods = await supabaseClient.from(database).select('*');
      return foods
          .map(
            (food) => DiningModel.fromJson(food).copyWith(
              name: food['name'],
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DiningModel> getFood({
    required String name,
  }) async {
    try {
      final food = await supabaseClient.from('food_modified').select('*').eq('name', name);
      return DiningModel.fromJson(food.first).copyWith(name: name);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DiningModel>> getFoodQuery({
    int? id,
    String? name,
    String? link,
    String? servingSize,
    String? servingsPerContainer,
    String? caloriesPerServing,
    String? totalFat,
    String? saturatedFat,
    String? transFat,
    String? cholesterol,
    String? sodium,
    String? totalCarbohydrates,
    String? dietaryFiber,
    String? totalSugar,
    String? addedSugar,
    String? protein,
  }) async {
    try {
      final table = supabaseClient.from('foods').select();
      var queriedFood = table;

      queriedFood = id != null ? queriedFood.eq('id', id) : queriedFood;
      queriedFood = name != null ? queriedFood.eq('name', name) : queriedFood;
      queriedFood = link != null ? queriedFood.eq('link', link) : queriedFood;
      queriedFood = servingSize != null ? queriedFood.eq('serving_size', servingSize) : queriedFood;
      queriedFood = servingsPerContainer != null ? queriedFood.eq('servings_per_container', servingsPerContainer) : queriedFood;
      queriedFood = caloriesPerServing != null ? queriedFood.eq('calories_per_serving', caloriesPerServing) : queriedFood;
      queriedFood = totalFat != null ? queriedFood.eq('total_fat', totalFat) : queriedFood;
      queriedFood = saturatedFat != null ? queriedFood.eq('saturated_fat', saturatedFat) : queriedFood;
      queriedFood = transFat != null ? queriedFood.eq('trans_fat', transFat) : queriedFood;
      queriedFood = cholesterol != null ? queriedFood.eq('cholesterol', cholesterol) : queriedFood;
      queriedFood = sodium != null ? queriedFood.eq('sodium', sodium) : queriedFood;
      queriedFood = totalCarbohydrates != null ? queriedFood.eq('total_carbohydrates', totalCarbohydrates) : queriedFood;
      queriedFood = dietaryFiber != null ? queriedFood.eq('dietary_fiber', dietaryFiber) : queriedFood;
      queriedFood = totalSugar != null ? queriedFood.eq('total_sugars', totalSugar) : queriedFood;
      queriedFood = addedSugar != null ? queriedFood.eq('added_sugars', addedSugar) : queriedFood;
      queriedFood = protein != null ? queriedFood.eq('protein', protein) : queriedFood;

      final response = await queriedFood.order('name', ascending: true);
      return response
          .map(
            (food) => DiningModel.fromJson(food).copyWith(
              name: food['name'],
              link: food['link'],
              servingSize: food['serving_size'],
              servingsPerContainer: food['servings_per_container'],
              caloriesPerServing: food['calories_per_serving'],
              totalFat: food['total_fat'],
              saturatedFat: food['saturated_fat'],
              transFat: food['trans_fat'],
              cholesterol: food['cholesterol'],
              sodium: food['sodium'],
              totalCarbohydrates: food['total_carbohydrates'],
              dietaryFiber: food['dietary_fiber'],
              totalSugar: food['total_sugars'],
              addedSugar: food['added_sugars'],
              protein: food['protein'],
            ),
          )
          .toList();
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
  Future<void> addFavoriteFood({required int foodId}) async {
    try {
      await supabaseClient.from('user_favorites').upsert({
        'user_id': supabaseClient.auth.currentUser!.id,
        'food_id': foodId,
      }, onConflict: 'user_id, food_id', ignoreDuplicates: true);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteFavoriteFood({required int foodId}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception("No user logged in");

      await supabaseClient.from('user_favorites').delete().match({
        'user_id': userId,
        'food_id': foodId,
      });

      print("✅ Successfully deleted favorite: $foodId for user: $userId");
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
