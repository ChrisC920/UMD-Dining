import 'package:umd_dining_refactor/core/errors/exceptions.dart';
import 'package:umd_dining_refactor/features/dining/data/models/dining_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DiningRemoteDataSource {
  Future<List<DiningModel>> getAllFoods();
  Future<DiningModel> getFood({
    required String name,
  });
  Future<List<DiningModel>> getFoodQuery({
    int? id,
    DateTime? createdAt,
    String? name,
    List<String>? diningHall,
    List<String>? section,
    List<String>? mealType,
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
    List<String>? allergens,
  });
}

class DiningRemoteDataSourceImpl implements DiningRemoteDataSource {
  final SupabaseClient supabaseClient;
  DiningRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<DiningModel>> getAllFoods() async {
    try {
      final foods = await supabaseClient.from('food_modified').select('*');
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
      final food = await supabaseClient
          .from('food_modified')
          .select('*')
          .eq('name', name);
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
    DateTime? createdAt,
    String? name,
    List<String>? diningHall,
    List<String>? section,
    List<String>? mealType,
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
    List<String>? allergens,
  }) async {
    try {
      final table = supabaseClient.from('food_modified').select();
      var queriedFood = table;

      queriedFood = id != null ? queriedFood.eq('id', id) : queriedFood;
      queriedFood = createdAt != null
          ? queriedFood.eq('created_at', createdAt)
          : queriedFood;
      queriedFood = name != null ? queriedFood.eq('name', name) : queriedFood;
      queriedFood = diningHall != null
          ? queriedFood.contains('dining_hall', diningHall)
          : queriedFood;
      queriedFood = section != null
          ? queriedFood.contains('section', section)
          : queriedFood;
      queriedFood = mealType != null
          ? queriedFood.contains('meal_type', mealType)
          : queriedFood;
      queriedFood = link != null ? queriedFood.eq('link', link) : queriedFood;
      queriedFood = servingSize != null
          ? queriedFood.eq('serving_size', servingSize)
          : queriedFood;
      queriedFood = servingsPerContainer != null
          ? queriedFood.eq('servings_per_container', servingsPerContainer)
          : queriedFood;
      queriedFood = caloriesPerServing != null
          ? queriedFood.eq('calories_per_serving', caloriesPerServing)
          : queriedFood;
      queriedFood = totalFat != null
          ? queriedFood.eq('total_fat', totalFat)
          : queriedFood;
      queriedFood = saturatedFat != null
          ? queriedFood.eq('saturated_fat', saturatedFat)
          : queriedFood;
      queriedFood = transFat != null
          ? queriedFood.eq('trans_fat', transFat)
          : queriedFood;
      queriedFood = cholesterol != null
          ? queriedFood.eq('cholesterol', cholesterol)
          : queriedFood;
      queriedFood =
          sodium != null ? queriedFood.eq('sodium', sodium) : queriedFood;
      queriedFood = totalCarbohydrates != null
          ? queriedFood.eq('total_carbohydrates', totalCarbohydrates)
          : queriedFood;
      queriedFood = dietaryFiber != null
          ? queriedFood.eq('dietary_fiber', dietaryFiber)
          : queriedFood;
      queriedFood = totalSugar != null
          ? queriedFood.eq('total_sugars', totalSugar)
          : queriedFood;
      queriedFood = addedSugar != null
          ? queriedFood.eq('added_sugars', addedSugar)
          : queriedFood;
      queriedFood =
          protein != null ? queriedFood.eq('protein', protein) : queriedFood;
      queriedFood = allergens != null
          ? queriedFood.containedBy('allergens', allergens)
          : queriedFood;

      final response = await queriedFood.order('name', ascending: true);
      return response
          .map(
            (food) => DiningModel.fromJson(food).copyWith(
              name: food['name'],
              diningHall: List.from(food['dining_hall']),
              section: List.from(food['section']),
              mealType: List.from(food['meal_type']),
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
              allergens: List.from(food['allergens']),
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
