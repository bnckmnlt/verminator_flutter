import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FoodWasteRemoteDatasource {
  Future<List<FoodWasteModel>> listFoodWaste();

  Future<FoodWasteModel> selectOneFoodWaste({
    required int id,
  });
}

class FoodWasteRemoteDatasourceImpl implements FoodWasteRemoteDatasource {
  final SupabaseClient supabaseClient;

  FoodWasteRemoteDatasourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<List<FoodWasteModel>> listFoodWaste() async {
    try {
      final response = await supabaseClient
          .from('food_waste')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((foodWaste) => FoodWasteModel.fromSupabaseJson(foodWaste))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FoodWasteModel> selectOneFoodWaste({
    required int id,
  }) async {
    try {
      final response = await supabaseClient
          .from('food_waste')
          .select()
          .eq('id', id)
          .single();

      return FoodWasteModel.fromSupabaseJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
