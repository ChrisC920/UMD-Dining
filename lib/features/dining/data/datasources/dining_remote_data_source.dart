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
      var query = supabaseClient.from('food_dates').select('''
  food_id, date_served,
  foods!inner (
    id, name, link, serving_size, servings_per_container, calories_per_serving, total_fat, saturated_fat, trans_fat,
    total_carbohydrates, dietary_fiber, total_sugars, added_sugars, cholesterol, sodium, protein,
    food_allergens!left (allergens (id, name)),
    food_dining_halls!left (dining_halls (id, name)),
    food_meal_types!left (meal_types (id, name)),
    food_sections!left (sections (id, name))
  )
''');

      // .order('date_served', ascending: false);

      // Filter by multiple dates
      if (dates != null && dates.isNotEmpty) {
        query = query.inFilter('date_served', dates);
      }

      // Filter by dining hall names
      if (diningHalls != null && diningHalls.isNotEmpty) {
        query = query.inFilter('foods.food_dining_halls.dining_halls.name', diningHalls);
      }

      // Filter by meal type names
      if (mealTypes != null && mealTypes.isNotEmpty) {
        query = query.inFilter('meal_types.name', mealTypes);
      }

      // Filter by section names
      if (sections != null && sections.isNotEmpty) {
        query = query.inFilter('sections.name', sections);
      }

      if (allergens != null && allergens.isNotEmpty) {
        query = query.inFilter('allergens.name', allergens);
      }

      final response = await query;
      final test = response
          .map((food) {
            try {
              return Food.fromJson(food);
            } catch (e, stacktrace) {
              print("Error parsing food item: $food");
              print("Error details: $e");
              print("Stacktrace: $stacktrace");
              return null; // Skip bad entries
            }
          })
          .whereType<Food>()
          .toList();

      // Convert response data into List<Food>
      return test;
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
}
